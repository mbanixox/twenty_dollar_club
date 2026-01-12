defmodule TwentyDollarClub.Jobs.PaymentCallbackWorker do
  @moduledoc """
  Processes M-Pesa payment callbacks asynchronously.

  This worker handles the payment verification and completion process
  for both membership and project contributions. It ensures:
  - Idempotent processing (safe to retry)
  - Automatic retries on failure
  - Proper error tracking
  - Transaction atomicity

  ## Configuration

  - Queue: `:payments` (high priority)
  - Max attempts: 10 (with exponential backoff)
  - Unique: 60 seconds (prevents duplicate processing)
  """
  use Oban.Worker,
    queue: :payments,
    max_attempts: 10,
    unique: [period: 60, fields: [:args], keys: [:checkout_request_id]]

  alias TwentyDollarClub.{Repo, Users, Memberships, Contributions}

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "checkout_request_id" => checkout_request_id,
          "result_code" => result_code,
          "callback" => callback
        }
      }) do
    Logger.info("Processing payment callback for checkout: #{checkout_request_id}")

    case Contributions.get_mpesa_transaction_by_checkout_id(checkout_request_id) do
      nil ->
        Logger.warning("M-Pesa transaction not found: #{checkout_request_id}")
        {:error, :transaction_not_found}

      mpesa_transaction ->
        handle_payment_result(mpesa_transaction, result_code, callback)
    end
  end

  defp handle_payment_result(mpesa_transaction, 0, callback) do
    # Payment successful
    mpesa_transaction = Repo.preload(mpesa_transaction, :contribution, force: true)
    contribution = mpesa_transaction.contribution

    # Check if already processed (idempotency)
    if contribution.status == :completed do
      Logger.info("Contribution already completed: #{contribution.id}")
      :ok
    else
      case contribution.contribution_type do
        :membership ->
          handle_membership_payment_success(mpesa_transaction, callback)

        :project ->
          handle_project_payment_success(mpesa_transaction, callback)

        _ ->
          Logger.warning("Unknown contribution type: #{contribution.contribution_type}")
          {:error, :unknown_contribution_type}
      end
    end
  end

  defp handle_payment_result(mpesa_transaction, _result_code, callback) do
    # Payment failed
    result_desc = callback["ResultDesc"]
    Logger.warning("Payment failed: #{result_desc}")

    # Check if already marked as failed (idempotency)
    mpesa_transaction = Repo.preload(mpesa_transaction, :contribution, force: true)

    if mpesa_transaction.contribution.status == :failed do
      Logger.info("Contribution already marked as failed: #{mpesa_transaction.contribution.id}")
      :ok
    else
      with {:ok, _} <-
             Contributions.update_mpesa_transaction_callback(mpesa_transaction, %{
               "result_code" => to_string(callback["ResultCode"]),
               "result_desc" => result_desc
             }),
           {:ok, _} <- Contributions.fail_contribution(mpesa_transaction.contribution) do
        Logger.info("Marked contribution as failed due to payment failure")
        :ok
      end
    end
  end

  defp handle_membership_payment_success(mpesa_transaction, callback) do
    receipt_number = get_callback_metadata(callback, "MpesaReceiptNumber")
    Logger.info("Payment successful for membership")

    result =
      Repo.transaction(fn ->
        with {:ok, updated_mpesa} <-
               update_mpesa_success(mpesa_transaction, receipt_number, callback),
             updated_mpesa <- Repo.preload(updated_mpesa, :contribution, force: true),
             {:ok, contribution} <-
               complete_contribution(updated_mpesa.contribution, receipt_number),
             {:ok, user} <- get_user_by_email(contribution.email),
             {:ok, membership} <- create_membership_for_user(user),
             {:ok, _contribution} <- Contributions.link_contribution_to_membership(contribution, membership.id) do
          Logger.info("Membership created successfully")
          {:ok, user.id, membership.generated_id, user.email}
        else
          {:error, reason} ->
            Logger.error("Failed to process successful membership payment: #{inspect(reason)}")
            Repo.rollback(reason)
        end
      end)

    case result do
      {:ok, {:ok, user_id, membership_id, email}} ->
        Logger.info(
          "Broadcasting membership creation for user_id=#{user_id}, membership_id=#{membership_id}"
        )

        Phoenix.PubSub.broadcast(
          TwentyDollarClub.PubSub,
          "payment:#{email}",
          {:membership_created, %{user_id: user_id, membership_id: membership_id}}
        )

        Logger.info("Broadcasted membership creation")
        :ok

      {:error, reason} ->
        Logger.error("Membership creation transaction failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp handle_project_payment_success(mpesa_transaction, callback) do
    receipt_number = get_callback_metadata(callback, "MpesaReceiptNumber")
    Logger.info("Payment successful for project")

    result =
      Repo.transaction(fn ->
        with {:ok, updated_mpesa} <-
               update_mpesa_success(mpesa_transaction, receipt_number, callback),
             updated_mpesa <- Repo.preload(updated_mpesa, :contribution, force: true),
             {:ok, contribution} <-
               complete_contribution(updated_mpesa.contribution, receipt_number),
             project when not is_nil(project) <-
               TwentyDollarClub.Projects.get_project!(contribution.project_id),
             {:ok, _updated_project} <-
               TwentyDollarClub.Projects.update_project(project, %{
                 funded_amount: Decimal.add(project.funded_amount || 0, contribution.amount)
               }) do
          Logger.info("Project contribution completed and funded_amount updated successfully")
          {:ok, contribution.id, contribution.project_id, contribution.email}
        else
          {:error, reason} ->
            Logger.error("Failed to process successful project payment: #{inspect(reason)}")
            Repo.rollback(reason)
          nil ->
            Logger.error("Project not found for contribution")
            Repo.rollback(:project_not_found)
        end
      end)

    case result do
      {:ok, {:ok, contribution_id, project_id, email}} ->
        Logger.info(
          "Broadcasting project payment for contribution_id=#{contribution_id}, project_id=#{project_id}"
        )

        Phoenix.PubSub.broadcast(
          TwentyDollarClub.PubSub,
          "payment:#{email}",
          {:project_paid, %{contribution_id: contribution_id, project_id: project_id}}
        )

        Logger.info("Broadcasted project payment")
        :ok

      {:error, reason} ->
        Logger.error("Project payment transaction failed: #{inspect(reason)}")
        {:error, reason}
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
      nil ->
        Logger.error("User not found: #{email}")
        {:error, :user_not_found}

      user ->
        Logger.debug("Found user: #{user.id}")
        {:ok, user}
    end
  end

  defp create_membership_for_user(user) do
    user = Repo.preload(user, :membership)

    case user.membership do
      nil ->
        Logger.info("Creating membership for user_id=#{user.id}")
        Memberships.create_membership(user, %{"role" => "member"})

      membership ->
        Logger.debug("User already has a membership (id=#{membership.id})")
        {:ok, membership}
    end
  end

  defp get_callback_metadata(callback, key) do
    callback
    |> Map.get("CallbackMetadata", %{})
    |> Map.get("Item", [])
    |> Enum.find(%{}, fn item -> item["Name"] == key end)
    |> Map.get("Value")
  end
end
