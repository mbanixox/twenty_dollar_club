defmodule TwentyDollarClub.Repo.Migrations.AddProjectContributionToMemberships do
  use Ecto.Migration

  def change do
    alter table(:memberships) do
      add :project_contribution_id, references(:project_contributions, type: :binary_id)
    end

    create index(:memberships, [:project_contribution_id])

  end
end
