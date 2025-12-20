defmodule TwentyDollarClub.Repo.Migrations.CreateProjectContributions do
  use Ecto.Migration

  def change do
    create table(:project_contributions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :total_amount_funded, :decimal
      add :goal_amount, :decimal
      add :project_id, references(:projects, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:project_contributions, [:project_id])
  end
end
