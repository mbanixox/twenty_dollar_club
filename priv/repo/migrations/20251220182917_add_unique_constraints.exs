defmodule TwentyDollarClub.Repo.Migrations.AddUniqueConstraints do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:email])
    create unique_index(:users, [:phone_number])
    create unique_index(:memberships, [:generated_id])
  end
end
