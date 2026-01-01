defmodule TwentyDollarClub.Repo.Migrations.AddEmailToContributions do
  use Ecto.Migration

  def change do
    alter table(:contributions) do
      add :email, :string
    end

    create index(:contributions, [:email])
    create index(:contributions, [:email, :status])
  end
end
