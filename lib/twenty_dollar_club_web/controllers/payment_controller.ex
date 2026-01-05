defmodule TwentyDollarClubWeb.PaymentController do
  @moduledoc """
  Handles payment-related actions.
  """

  use TwentyDollarClubWeb, :controller

  alias TwentyDollarClub.{Users, Projects, Contributions}
  alias TwentyDollarClub.Mpesa.StkPush
  alias TwentyDollarClubWeb.FallbackController

  require Logger

  action_fallback FallbackController

  @doc """
  Initiates an M-Pesa STK Push request for membership creation.
  """
  def create_membership_mpesa(conn, %{"email" => email, "phone" => phone, "amount" => amount}) do
    Logger.info("Initiating membership payment")

    user = conn.assigns.user
    contribution_type = :membership
    description = "Membership registration"

    with {:ok, _} <- Users.validate_no_membership(user),
         {:ok, contribution} <-
           create_pending_contribution(email, phone, amount, description, contribution_type),
         {:ok, response} <- initiate_stk_push(phone, amount, contribution.id, contribution_type),
         {:ok, _mpesa_txn} <- save_mpesa_transaction(contribution.id, response.body) do
      Logger.info("STK push sent successfully ")

      conn
      |> put_status(:ok)
      |> json(%{
        status: "success",
        message: "STK push sent. Please enter PIN on your phone.",
        contribution_id: contribution.id,
        checkout_request_id: response.body["CheckoutRequestID"]
      })
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.warning("Validation error during membership payment")

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", errors: translate_errors(changeset)})

      {:error, :already_has_membership} ->
        Logger.warning("User already has an active membership")

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", message: "User already has an active membership"})

      {:error, _reason} ->
        Logger.error("Membership payment initiation failed")

        conn
        |> put_status(:bad_request)
        |> json(%{status: "error", message: "Payment initiation failed"})
    end
  end

  def project_payment_mpesa(conn, %{
        "project_id" => project_id,
        "phone" => phone,
        "amount" => amount
      }) do
    Logger.info("Initiating project payment")

    user = conn.assigns.user
    membership = user.membership
    contribution_type = :project
    description = Projects.get_project!(project_id).title

    with true <- not is_nil(membership),
         {:ok, contribution} <-
           create_pending_contribution(user.email, phone, amount, description, contribution_type),
         {:ok, _} <- Contributions.link_contribution_to_membership(contribution, membership.id),
         {:ok, _} <- Contributions.link_contribution_to_project(contribution, project_id),
         {:ok, response} <- initiate_stk_push(phone, amount, contribution.id, contribution_type),
         {:ok, _mpesa_txn} <- save_mpesa_transaction(contribution.id, response.body) do
      Logger.info("STK push sent successfully for project payment")

      conn
      |> put_status(:ok)
      |> json(%{
        status: "success",
        message: "STK push sent. Please enter PIN on your phone.",
        contribution_id: contribution.id,
        checkout_request_id: response.body["CheckoutRequestID"]
      })
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.warning("Validation error during project payment")

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", errors: translate_errors(changeset)})

      {:error, _reason} ->
        Logger.error("Project payment initiation failed")

        conn
        |> put_status(:bad_request)
        |> json(%{status: "error", message: "Payment initiation failed"})
    end
  end

  @doc """
  Handles M-Pesa callback.
  Enqueues the callback processing to Oban for reliable, async handling.
  """
  def mpesa_callback(conn, %{"Body" => %{"stkCallback" => callback}}) do
    Logger.info("Received M-Pesa callback")

    # Extract key data for job processing
    checkout_request_id = callback["CheckoutRequestID"]
    result_code = callback["ResultCode"]

    # Enqueue the job to Oban for processing
    %{
      checkout_request_id: checkout_request_id,
      result_code: result_code,
      callback: callback
    }
    |> TwentyDollarClub.Jobs.PaymentCallbackWorker.new()
    |> Oban.insert()
    |> case do
      {:ok, _job} ->
        Logger.info("Payment callback job enqueued: #{checkout_request_id}")

      {:error, reason} ->
        Logger.error("Failed to enqueue payment callback job: #{inspect(reason)}")
    end

    # Always return success to M-Pesa immediately
    json(conn, %{ResultCode: 0, ResultDesc: "Accepted"})
  end

  def mpesa_callback(conn, _params) do
    Logger.warning("Received M-Pesa callback with unexpected params")
    json(conn, %{ResultCode: 0, ResultDesc: "Accepted"})
  end

  defp create_pending_contribution(email, phone, amount, description, contribution_type) do
    Logger.info("Creating pending contribution")

    Contributions.create_pending_contribution(%{
      payment_method: "mpesa",
      amount: amount,
      description: description,
      phone_number: phone,
      email: email,
      contribution_type: contribution_type
    })
  end

  defp initiate_stk_push(phone, amount, contribution_id, contribution_type) do
    reference = "#{contribution_type}-#{contribution_id}"
    Logger.info("Initiating STK push")
    StkPush.push(phone, amount, reference)
  end

  defp save_mpesa_transaction(contribution_id, response_body) do
    Logger.info("Saving M-Pesa transaction record")

    Contributions.create_mpesa_transaction(contribution_id, %{
      "merchant_request_id" => response_body["MerchantRequestID"],
      "checkout_request_id" => response_body["CheckoutRequestID"],
      "response_code" => response_body["ResponseCode"],
      "response_description" => response_body["ResponseDescription"],
      "customer_message" => response_body["CustomerMessage"]
    })
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
