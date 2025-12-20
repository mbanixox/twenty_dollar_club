defmodule TwentyDollarClub.ProjectContributionsTest do
  use TwentyDollarClub.DataCase

  alias TwentyDollarClub.ProjectContributions

  describe "project_contributions" do
    alias TwentyDollarClub.ProjectContributions.ProjectContribution

    import TwentyDollarClub.ProjectContributionsFixtures

    @invalid_attrs %{total_amount_funded: nil, goal_amount: nil}

    test "list_project_contributions/0 returns all project_contributions" do
      project_contribution = project_contribution_fixture()
      assert ProjectContributions.list_project_contributions() == [project_contribution]
    end

    test "get_project_contribution!/1 returns the project_contribution with given id" do
      project_contribution = project_contribution_fixture()
      assert ProjectContributions.get_project_contribution!(project_contribution.id) == project_contribution
    end

    test "create_project_contribution/1 with valid data creates a project_contribution" do
      valid_attrs = %{total_amount_funded: "120.5", goal_amount: "120.5"}

      assert {:ok, %ProjectContribution{} = project_contribution} = ProjectContributions.create_project_contribution(valid_attrs)
      assert project_contribution.total_amount_funded == Decimal.new("120.5")
      assert project_contribution.goal_amount == Decimal.new("120.5")
    end

    test "create_project_contribution/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ProjectContributions.create_project_contribution(@invalid_attrs)
    end

    test "update_project_contribution/2 with valid data updates the project_contribution" do
      project_contribution = project_contribution_fixture()
      update_attrs = %{total_amount_funded: "456.7", goal_amount: "456.7"}

      assert {:ok, %ProjectContribution{} = project_contribution} = ProjectContributions.update_project_contribution(project_contribution, update_attrs)
      assert project_contribution.total_amount_funded == Decimal.new("456.7")
      assert project_contribution.goal_amount == Decimal.new("456.7")
    end

    test "update_project_contribution/2 with invalid data returns error changeset" do
      project_contribution = project_contribution_fixture()
      assert {:error, %Ecto.Changeset{}} = ProjectContributions.update_project_contribution(project_contribution, @invalid_attrs)
      assert project_contribution == ProjectContributions.get_project_contribution!(project_contribution.id)
    end

    test "delete_project_contribution/1 deletes the project_contribution" do
      project_contribution = project_contribution_fixture()
      assert {:ok, %ProjectContribution{}} = ProjectContributions.delete_project_contribution(project_contribution)
      assert_raise Ecto.NoResultsError, fn -> ProjectContributions.get_project_contribution!(project_contribution.id) end
    end

    test "change_project_contribution/1 returns a project_contribution changeset" do
      project_contribution = project_contribution_fixture()
      assert %Ecto.Changeset{} = ProjectContributions.change_project_contribution(project_contribution)
    end
  end
end
