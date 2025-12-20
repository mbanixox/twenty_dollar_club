defmodule TwentyDollarClub.Repo.Migrations.CreateContributions do
  use Ecto.Migration

  def change do
    create table(:contributions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :transaction_reference, :string
      add :payment_method, :string
      add :membership_id, references(:memberships, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:contributions, [:membership_id])
  end
end
