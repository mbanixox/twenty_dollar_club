defmodule TwentyDollarClubWeb.ProjectControllerTest do
  use TwentyDollarClubWeb.ConnCase

  import TwentyDollarClub.ProjectsFixtures
  alias TwentyDollarClub.Projects.Project

  @create_attrs %{
    status: "some status",
    description: "some description",
    title: "some title",
    goal_amount: "120.5",
    funded_amount: "120.5"
  }
  @update_attrs %{
    status: "some updated status",
    description: "some updated description",
    title: "some updated title",
    goal_amount: "456.7",
    funded_amount: "456.7"
  }
  @invalid_attrs %{status: nil, description: nil, title: nil, goal_amount: nil, funded_amount: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all projects", %{conn: conn} do
      conn = get(conn, ~p"/api/projects")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create project" do
    test "renders project when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/projects", project: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/projects/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "funded_amount" => "120.5",
               "goal_amount" => "120.5",
               "status" => "some status",
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/projects", project: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update project" do
    setup [:create_project]

    test "renders project when data is valid", %{conn: conn, project: %Project{id: id} = project} do
      conn = put(conn, ~p"/api/projects/#{project}", project: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/projects/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "funded_amount" => "456.7",
               "goal_amount" => "456.7",
               "status" => "some updated status",
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, project: project} do
      conn = put(conn, ~p"/api/projects/#{project}", project: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete project" do
    setup [:create_project]

    test "deletes chosen project", %{conn: conn, project: project} do
      conn = delete(conn, ~p"/api/projects/#{project}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/projects/#{project}")
      end
    end
  end

  defp create_project(_) do
    project = project_fixture()

    %{project: project}
  end
end
