defmodule TwentyDollarClub.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string
      add :last_name, :string
      add :email, :string
      add :phone_number, :string
      add :gender, :string

      timestamps(type: :utc_datetime)
    end
  end
end
