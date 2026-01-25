defmodule TwentyDollarClub.Repo.Migrations.AddMembershipStatusToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :membership_status, :string, default: "pending", null: false
    end
  end
end
