defmodule TwentyDollarClub.Contributions.Contribution do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contributions" do
    field :transaction_reference, :string
    field :payment_method, :string
    field :membership_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(contribution, attrs) do
    contribution
    |> cast(attrs, [:transaction_reference, :payment_method])
    |> validate_required([:transaction_reference, :payment_method])
  end
end
