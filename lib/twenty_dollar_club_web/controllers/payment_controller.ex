defmodule TwentyDollarClubWeb.PaymentController do
  @moduledoc """
  Handles payment-related actions.
  """

  use TwentyDollarClubWeb, :controller

  alias TwentyDollarClub.{Repo, Users, Memberships, Contributions}
  alias TwentyDollarClub.Mpesa.StkPush
  alias TwentyDollarClubWeb.FallbackController

  require Logger

  action_fallback FallbackController

  @doc """
  Initiates an M-Pesa STK Push request for membership creation.
  """
  def create_membership_mpesa(conn, %{"email" => email, "phone" => phone, "amount" => amount}) do
    with {:ok, user} <- get_or_create_user(email),
         {:ok, _} <- validate_no_membership(user),
         {:ok, contribution} <- create_pending_contribution(email, phone, amount),
         {:ok, response} <- initiate_stk_push(phone, amount, contribution.id),
         {:ok, _mpesa_txn} <- save_mpesa_transaction(contribution.id, response.body) do
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
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", errors: translate_errors(changeset)})

      {:error, :already_has_membership} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", message: "User already has an active membership"})

      {:error, reason} ->
        Logger.error("Membership payment failed: #{inspect(reason)}")

        conn
        |> put_status(:bad_request)
        |> json(%{status: "error", message: "Payment initiation failed"})
    end
  end

  @doc """
  Handles M-Pesa callback.
  """
  def mpesa_callback(conn, %{"Body" => %{"stkCallback" => callback}}) do
    Task.start(fn -> process_callback(callback) end)

    json(conn, %{ResultCode: 0, ResultDesc: "Accepted"})
  end

  def mpesa_callback(conn, _params) do
    json(conn, %{ResultCode: 0, ResultDesc: "Accepted"})
  end

  defp get_or_create_user(email) do
    case Users.get_user_by_email(email) do
      nil ->
        Users.create_user(%{email: email, name: email})

      user ->
        {:ok, user}
    end
  end

  defp validate_no_membership(user) do
    user = Repo.preload(user, :membership)

    case user.membership do
      nil -> {:ok, user}
      _membership -> {:error, :already_has_membership}
    end
  end

  defp create_pending_contribution(email, phone, amount) do
    Contributions.create_pending_contribution(%{
      payment_method: "mpesa",
      amount: amount,
      description: "Membership registration",
      phone_number: phone,
      email: email
    })
  end

  defp initiate_stk_push(phone, amount, contribution_id) do
    reference = "MEMBERSHIP-#{contribution_id}"
    StkPush.push(phone, amount, reference)
  end

  defp save_mpesa_transaction(contribution_id, response_body) do
    Contributions.create_mpesa_transaction(contribution_id, %{
      "merchant_request_id" => response_body["MerchantRequestID"],
      "checkout_request_id" => response_body["CheckoutRequestID"],
      "response_code" => response_body["ResponseCode"],
      "response_description" => response_body["ResponseDescription"],
      "customer_message" => response_body["CustomerMessage"]
    })
  end

  defp process_callback(
         %{"CheckoutRequestID" => checkout_request_id, "ResultCode" => result_code} = callback
       ) do
    Logger.info("Processing M-Pesa callback: #{inspect(callback)}")

    case Contributions.get_mpesa_transaction_by_checkout_id(checkout_request_id) do
      nil ->
        Logger.warning("M-Pesa transaction not found: #{checkout_request_id}")

      mpesa_transaction ->
        handle_payment_result(mpesa_transaction, result_code, callback)
    end
  end

  defp handle_payment_result(mpesa_transaction, 0, callback) do
    # Payment successful
    receipt_number = get_callback_metadata(callback, "MpesaReceiptNumber")

    result =
      Repo.transaction(fn ->
        with {:ok, updated_mpesa} <-
               update_mpesa_success(mpesa_transaction, receipt_number, callback),
             # Reload the contribution association after update
             updated_mpesa <- Repo.preload(updated_mpesa, :contribution, force: true),
             {:ok, contribution} <-
               complete_contribution(updated_mpesa.contribution, receipt_number),
             {:ok, user} <- get_user_by_email(contribution.email),
             {:ok, membership} <- create_membership_for_user(user),
             {:ok, _contribution} <- link_contribution_to_membership(contribution, membership.id) do
          Logger.info("Membership created successfully for user #{user.email}")
          {:ok, user.id, membership.generated_id, user.email}
        else
          {:error, reason} ->
            Logger.error("Failed to process successful payment: #{inspect(reason)}")
            Repo.rollback(reason)
        end
      end)

    # Broadcast AFTER transaction commits
    case result do
      {:ok, {:ok, user_id, membership_id, email}} ->
        Phoenix.PubSub.broadcast(
          TwentyDollarClub.PubSub,
          "payment:#{email}",
          {:membership_created, %{user_id: user_id, membership_id: membership_id}}
        )

        Logger.info("Broadcasted membership creation for #{email}")

      _ ->
        :ok
    end

    result
  end

  defp handle_payment_result(mpesa_transaction, _result_code, callback) do
    # Payment failed
    result_desc = callback["ResultDesc"]

    with {:ok, _} <-
           Contributions.update_mpesa_transaction_callback(mpesa_transaction, %{
             "result_code" => to_string(callback["ResultCode"]),
             "result_desc" => result_desc
           }),
         {:ok, _} <- Contributions.fail_contribution(mpesa_transaction.contribution) do
      Logger.info(
        "Payment failed for contribution #{mpesa_transaction.contribution.id}: #{result_desc}"
      )
    end
  end

  defp update_mpesa_success(mpesa_transaction, receipt_number, callback) do
    Contributions.update_mpesa_transaction_callback(mpesa_transaction, %{
      "mpesa_receipt_number" => receipt_number,
      "result_code" => "0",
      "result_desc" => callback["ResultDesc"]
    })
  end

  defp complete_contribution(contribution, receipt_number) do
    Contributions.complete_contribution(contribution, receipt_number)
  end

  defp get_user_by_email(email) do
    case Users.get_user_by_email(email) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  defp create_membership_for_user(user) do
    user = Repo.preload(user, :membership)

    case user.membership do
      nil ->
        Memberships.create_membership(user, %{"role" => "member"})

      membership ->
        {:ok, membership}
    end
  end

  defp link_contribution_to_membership(contribution, membership_id) do
    Contributions.update_contribution_membership(contribution, membership_id)
  end

  defp get_callback_metadata(callback, key) do
    callback
    |> Map.get("CallbackMetadata", %{})
    |> Map.get("Item", [])
    |> Enum.find(%{}, fn item -> item["Name"] == key end)
    |> Map.get("Value")
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
