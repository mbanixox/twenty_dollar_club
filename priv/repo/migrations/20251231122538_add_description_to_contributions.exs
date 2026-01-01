defmodule TwentyDollarClub.Repo.Migrations.AddDescriptionToContributions do
  use Ecto.Migration

  def change do
    alter table(:contributions) do
      add :description, :string
    end
  end
end
