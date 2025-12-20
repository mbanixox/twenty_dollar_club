defmodule TwentyDollarClub.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :description, :text
      add :status, :string
      add :goal_amount, :decimal
      add :funded_amount, :decimal
      add :membership_id, references(:memberships, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:projects, [:membership_id])
  end
end
