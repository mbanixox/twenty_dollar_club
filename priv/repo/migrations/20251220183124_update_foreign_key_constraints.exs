defmodule TwentyDollarClub.Repo.Migrations.UpdateForeignKeyConstraints do
  use Ecto.Migration

  def up do
    # Drop existing foreign keys
    drop constraint(:memberships, "memberships_user_id_fkey")
    drop constraint(:beneficiaries, "beneficiaries_membership_id_fkey")
    drop constraint(:projects, "projects_membership_id_fkey")
    drop constraint(:contributions, "contributions_membership_id_fkey")
    drop constraint(:project_contributions, "project_contributions_project_id_fkey")

    # Add them back with new on_delete strategies
    alter table(:memberships) do
      modify :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
    end

    alter table(:beneficiaries) do
      modify :membership_id, references(:memberships, on_delete: :delete_all, type: :binary_id)
    end

    alter table(:projects) do
      modify :membership_id, references(:memberships, on_delete: :nilify_all, type: :binary_id)
    end

    alter table(:contributions) do
      modify :membership_id, references(:memberships, on_delete: :nilify_all, type: :binary_id)
    end

    alter table(:project_contributions) do
      modify :project_id, references(:projects, on_delete: :delete_all, type: :binary_id)
    end
  end

  def down do
    # Reverse the changes (during rollback)
    drop constraint(:memberships, "memberships_user_id_fkey")
    drop constraint(:beneficiaries, "beneficiaries_membership_id_fkey")
    drop constraint(:projects, "projects_membership_id_fkey")
    drop constraint(:contributions, "contributions_membership_id_fkey")
    drop constraint(:project_contributions, "project_contributions_project_id_fkey")

    alter table(:memberships) do
      modify :user_id, references(:users, on_delete: :nothing, type: :binary_id)
    end

    alter table(:beneficiaries) do
      modify :membership_id, references(:memberships, on_delete: :nothing, type: :binary_id)
    end

    alter table(:projects) do
      modify :membership_id, references(:memberships, on_delete: :nothing, type: :binary_id)
    end

    alter table(:contributions) do
      modify :membership_id, references(:memberships, on_delete: :nothing, type: :binary_id)
    end

    alter table(:project_contributions) do
      modify :project_id, references(:projects, on_delete: :nothing, type: :binary_id)
    end
  end
end
