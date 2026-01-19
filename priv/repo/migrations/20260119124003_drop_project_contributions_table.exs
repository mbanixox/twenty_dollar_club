defmodule TwentyDollarClub.Repo.Migrations.DropProjectContributionsTable do
  use Ecto.Migration

  def change do
    alter table(:memberships) do
      remove :project_contribution_id
    end

    drop table(:project_contributions)
  end
end
