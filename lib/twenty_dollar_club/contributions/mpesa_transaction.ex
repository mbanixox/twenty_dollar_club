defmodule TwentyDollarClub.Contributions.MpesaTransaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "mpesa_transactions" do
    field :merchant_request_id, :string
    field :checkout_request_id, :string
    field :response_code, :string
    field :response_description, :string
    field :customer_message, :string
    field :mpesa_receipt_number, :string
    field :result_code, :string
    field :result_desc, :string
    field :callback_received_at, :utc_datetime

    belongs_to :contribution, TwentyDollarClub.Contributions.Contribution

    timestamps(type: :utc_datetime)
  end

  def stk_push_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:merchant_request_id, :checkout_request_id, :response_code,
                    :response_description, :customer_message, :contribution_id])
    |> validate_required([:merchant_request_id, :checkout_request_id, :contribution_id])
    |> foreign_key_constraint(:contribution_id)
    |> unique_constraint(:merchant_request_id)
    |> unique_constraint(:checkout_request_id)
  end

  def callback_changeset(mpesa_transaction, attrs) do
    mpesa_transaction
    |> cast(attrs, [:mpesa_receipt_number, :result_code, :result_desc])
    |> validate_required([:result_code])
    |> put_change(:callback_received_at, DateTime.utc_now() |> DateTime.truncate(:second))
  end
end
