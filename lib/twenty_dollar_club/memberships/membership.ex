defmodule TwentyDollarClub.Memberships.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "memberships" do
    field :generated_id, :integer
    field :role, Ecto.Enum, values: [:member, :admin], default: :member
    belongs_to :user, TwentyDollarClub.Users.User
    has_many :beneficiaries, TwentyDollarClub.Beneficiaries.Beneficiary
    has_many :projects, TwentyDollarClub.Projects.Project
    has_many :contributions, TwentyDollarClub.Contributions.Contribution
    belongs_to :project_contribution, TwentyDollarClub.ProjectContributions.ProjectContribution

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:generated_id, :role])
    |> validate_required([:role])
  end
end
