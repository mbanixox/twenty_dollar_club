defmodule TwentyDollarClubWeb.ContributionController do
  use TwentyDollarClubWeb, :controller

  alias TwentyDollarClub.Contributions

  action_fallback TwentyDollarClubWeb.FallbackController

  def index(conn, _params) do
    contributions = Contributions.list_contributions()
    render(conn, :index, contributions: contributions)
  end

  def show(conn, %{"id" => id}) do
    contribution = Contributions.get_contribution!(id)
    render(conn, :show, contribution: contribution)
  end

  def member_contributions(conn, %{"member_id" => member_id}) do
    contributions = Contributions.list_member_contributions(member_id)
    render(conn, :index, contributions: contributions)
  end

  def project_contributions(conn, %{"project_id" => project_id}) do
    contributions = Contributions.list_project_contributions(project_id)
    render(conn, :index, contributions: contributions)
  end
end
