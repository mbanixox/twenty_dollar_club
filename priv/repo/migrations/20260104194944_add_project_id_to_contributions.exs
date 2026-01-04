defmodule TwentyDollarClub.Repo.Migrations.AddProjectIdToContributions do
  use Ecto.Migration

  def change do
    alter table(:contributions) do
      add :project_id, references(:projects, type: :binary_id, on_delete: :nilify_all)
    end

    create index(:contributions, [:project_id])
  end
end
