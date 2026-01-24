defmodule TwentyDollarClub.Beneficiaries.Beneficiary do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "beneficiaries" do
    field :beneficiary_name, :string
    field :relationship, Ecto.Enum, values: [:spouse, :child, :parent, :sibling, :relative, :friend]
    belongs_to :membership, TwentyDollarClub.Memberships.Membership

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(beneficiary, attrs) do
    beneficiary
    |> cast(attrs, [:beneficiary_name, :relationship])
    |> validate_required([:beneficiary_name, :relationship])
  end
end
