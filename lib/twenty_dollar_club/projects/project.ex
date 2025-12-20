defmodule TwentyDollarClub.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "projects" do
    field :title, :string
    field :description, :string
    field :status, :string
    field :goal_amount, :decimal
    field :funded_amount, :decimal
    field :membership_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:title, :description, :status, :goal_amount, :funded_amount])
    |> validate_required([:title, :description, :status, :goal_amount, :funded_amount])
  end
end
