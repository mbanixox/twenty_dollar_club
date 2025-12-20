defmodule TwentyDollarClub.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projects" do
    field :title, :string
    field :description, :string
    field :status, Ecto.Enum, values: [:active, :completed, :paused], default: :active
    field :goal_amount, :decimal
    field :funded_amount, :decimal
    belongs_to :membership, TwentyDollarClub.Memberships.Membership
    has_one :project_contributions, TwentyDollarClub.ProjectContributions.ProjectContribution

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:title, :description, :status, :goal_amount, :funded_amount])
    |> validate_required([:title, :description, :status, :goal_amount, :funded_amount])
  end
end
