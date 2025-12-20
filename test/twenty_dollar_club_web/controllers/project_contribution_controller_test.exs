defmodule TwentyDollarClubWeb.ProjectContributionControllerTest do
  use TwentyDollarClubWeb.ConnCase

  import TwentyDollarClub.ProjectContributionsFixtures
  alias TwentyDollarClub.ProjectContributions.ProjectContribution

  @create_attrs %{
    total_amount_funded: "120.5",
    goal_amount: "120.5"
  }
  @update_attrs %{
    total_amount_funded: "456.7",
    goal_amount: "456.7"
  }
  @invalid_attrs %{total_amount_funded: nil, goal_amount: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all project_contributions", %{conn: conn} do
      conn = get(conn, ~p"/api/project_contributions")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create project_contribution" do
    test "renders project_contribution when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/project_contributions", project_contribution: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/project_contributions/#{id}")

      assert %{
               "id" => ^id,
               "goal_amount" => "120.5",
               "total_amount_funded" => "120.5"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/project_contributions", project_contribution: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update project_contribution" do
    setup [:create_project_contribution]

    test "renders project_contribution when data is valid", %{conn: conn, project_contribution: %ProjectContribution{id: id} = project_contribution} do
      conn = put(conn, ~p"/api/project_contributions/#{project_contribution}", project_contribution: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/project_contributions/#{id}")

      assert %{
               "id" => ^id,
               "goal_amount" => "456.7",
               "total_amount_funded" => "456.7"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, project_contribution: project_contribution} do
      conn = put(conn, ~p"/api/project_contributions/#{project_contribution}", project_contribution: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete project_contribution" do
    setup [:create_project_contribution]

    test "deletes chosen project_contribution", %{conn: conn, project_contribution: project_contribution} do
      conn = delete(conn, ~p"/api/project_contributions/#{project_contribution}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/project_contributions/#{project_contribution}")
      end
    end
  end

  defp create_project_contribution(_) do
    project_contribution = project_contribution_fixture()

    %{project_contribution: project_contribution}
  end
end
