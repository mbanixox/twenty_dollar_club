defmodule TwentyDollarClubWeb.ProjectContributionController do
  use TwentyDollarClubWeb, :controller

  alias TwentyDollarClub.ProjectContributions
  alias TwentyDollarClub.ProjectContributions.ProjectContribution

  action_fallback TwentyDollarClubWeb.FallbackController

  def index(conn, _params) do
    project_contributions = ProjectContributions.list_project_contributions()
    render(conn, :index, project_contributions: project_contributions)
  end

  def create(conn, %{"project_contribution" => project_contribution_params}) do
    with {:ok, %ProjectContribution{} = project_contribution} <- ProjectContributions.create_project_contribution(project_contribution_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/project_contributions/#{project_contribution}")
      |> render(:show, project_contribution: project_contribution)
    end
  end

  def show(conn, %{"id" => id}) do
    project_contribution = ProjectContributions.get_project_contribution!(id)
    render(conn, :show, project_contribution: project_contribution)
  end

  def update(conn, %{"id" => id, "project_contribution" => project_contribution_params}) do
    project_contribution = ProjectContributions.get_project_contribution!(id)

    with {:ok, %ProjectContribution{} = project_contribution} <- ProjectContributions.update_project_contribution(project_contribution, project_contribution_params) do
      render(conn, :show, project_contribution: project_contribution)
    end
  end

  def delete(conn, %{"id" => id}) do
    project_contribution = ProjectContributions.get_project_contribution!(id)

    with {:ok, %ProjectContribution{}} <- ProjectContributions.delete_project_contribution(project_contribution) do
      send_resp(conn, :no_content, "")
    end
  end
end
