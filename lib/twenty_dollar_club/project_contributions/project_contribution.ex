defmodule TwentyDollarClub.ProjectContributions.ProjectContribution do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "project_contributions" do
    field :total_amount_funded, :decimal
    field :goal_amount, :decimal
    belongs_to :project, TwentyDollarClub.Projects.Project
    has_many :memberships, TwentyDollarClub.Memberships.Membership

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project_contribution, attrs) do
    project_contribution
    |> cast(attrs, [:total_amount_funded, :goal_amount])
    |> validate_required([:total_amount_funded, :goal_amount])
  end
end
