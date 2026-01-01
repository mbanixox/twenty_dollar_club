defmodule TwentyDollarClub.Repo.Migrations.AddFieldsToContributions do
  use Ecto.Migration

  def change do
    alter table(:contributions) do
      add :status, :string, null: false, default: "pending"
      add :phone_number, :string
    end

    create index(:contributions, [:status])
    create index(:contributions, [:transaction_reference], unique: true)
  end
end
