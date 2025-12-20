defmodule TwentyDollarClub.Repo.Migrations.AddAmountToContributions do
  use Ecto.Migration

  def change do
    alter table(:contributions) do
      add :amount, :decimal, null: false
    end
  end
end
