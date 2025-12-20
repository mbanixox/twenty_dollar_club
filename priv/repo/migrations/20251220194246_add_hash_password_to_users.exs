defmodule TwentyDollarClub.Repo.Migrations.AddHashPasswordToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :hashed_password, :string
    end
  end
end
