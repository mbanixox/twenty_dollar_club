defmodule TwentyDollarClub.Repo.Migrations.AddContributionTypeToContributions do
  use Ecto.Migration

  def change do
    alter table(:contributions) do
      add :contribution_type, :string, default: "membership", null: false
    end
  end
end
