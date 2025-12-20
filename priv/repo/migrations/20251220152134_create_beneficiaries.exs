defmodule TwentyDollarClub.Repo.Migrations.CreateBeneficiaries do
  use Ecto.Migration

  def change do
    create table(:beneficiaries, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :beneficiary_name, :string
      add :relationship, :string
      add :membership_id, references(:memberships, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:beneficiaries, [:membership_id])
  end
end
