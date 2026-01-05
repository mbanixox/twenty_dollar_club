defmodule TwentyDollarClub.Memberships.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "memberships" do
    field :generated_id, :integer
    field :role, Ecto.Enum, values: [:member, :admin, :super_admin], default: :member
    belongs_to :user, TwentyDollarClub.Users.User
    has_many :beneficiaries, TwentyDollarClub.Beneficiaries.Beneficiary
    has_many :projects, TwentyDollarClub.Projects.Project
    has_many :contributions, TwentyDollarClub.Contributions.Contribution

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:role])
    |> put_generated_id()
    |> validate_required([:role, :generated_id])
    |> unique_constraint(:generated_id)
  end

  defp put_generated_id(changeset) do
    case get_field(changeset, :generated_id) do
      nil -> put_change(changeset, :generated_id, generate_membership_id())
      _ -> changeset
    end
  end

  defp generate_membership_id() do
    :rand.uniform(999_999_999)
  end

  def allowed_role_update?(current_role, new_role) do
    case {current_role, new_role} do
      {:admin, :admin} -> true
      {:admin, :member} -> true
      {:admin, :super_admin} -> false
      {:super_admin, _} -> true
      _ -> false
    end
  end
end
