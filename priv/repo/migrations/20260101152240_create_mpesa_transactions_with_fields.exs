defmodule TwentyDollarClub.Repo.Migrations.CreateMpesaTransactionsWithFields do
  use Ecto.Migration

  def change do
    create table(:mpesa_transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :merchant_request_id, :string, null: false
      add :checkout_request_id, :string, null: false
      add :response_code, :string
      add :response_description, :string
      add :customer_message, :string
      add :mpesa_receipt_number, :string
      add :result_code, :string
      add :result_desc, :string
      add :callback_received_at, :utc_datetime
      add :contribution_id, references(:contributions, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:mpesa_transactions, [:merchant_request_id])
    create unique_index(:mpesa_transactions, [:checkout_request_id])
    create index(:mpesa_transactions, [:contribution_id])
  end
end
