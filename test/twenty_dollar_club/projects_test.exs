defmodule TwentyDollarClub.ProjectsTest do
  use TwentyDollarClub.DataCase

  alias TwentyDollarClub.Projects

  describe "projects" do
    alias TwentyDollarClub.Projects.Project

    import TwentyDollarClub.ProjectsFixtures

    @invalid_attrs %{status: nil, description: nil, title: nil, goal_amount: nil, funded_amount: nil}

    test "list_projects/0 returns all projects" do
      project = project_fixture()
      assert Projects.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert Projects.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      valid_attrs = %{status: "some status", description: "some description", title: "some title", goal_amount: "120.5", funded_amount: "120.5"}

      assert {:ok, %Project{} = project} = Projects.create_project(valid_attrs)
      assert project.status == "some status"
      assert project.description == "some description"
      assert project.title == "some title"
      assert project.goal_amount == Decimal.new("120.5")
      assert project.funded_amount == Decimal.new("120.5")
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Projects.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()
      update_attrs = %{status: "some updated status", description: "some updated description", title: "some updated title", goal_amount: "456.7", funded_amount: "456.7"}

      assert {:ok, %Project{} = project} = Projects.update_project(project, update_attrs)
      assert project.status == "some updated status"
      assert project.description == "some updated description"
      assert project.title == "some updated title"
      assert project.goal_amount == Decimal.new("456.7")
      assert project.funded_amount == Decimal.new("456.7")
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = Projects.update_project(project, @invalid_attrs)
      assert project == Projects.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = Projects.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = Projects.change_project(project)
    end
  end
end
