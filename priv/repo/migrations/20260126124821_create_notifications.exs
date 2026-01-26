defmodule TwentyDollarClub.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event, :string
      add :message, :string
      add :read, :boolean, default: false, null: false
      add :severity, :string
      add :recipient_type, :string
      add :resource_type, :string
      add :membership_id, references(:memberships, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:notifications, [:membership_id])
  end
end
