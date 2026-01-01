defmodule TwentyDollarClubWeb.ContributionController do
  use TwentyDollarClubWeb, :controller

  alias TwentyDollarClub.Contributions
  alias TwentyDollarClub.Contributions.Contribution

  action_fallback TwentyDollarClubWeb.FallbackController

  def index(conn, _params) do
    contributions = Contributions.list_contributions()
    render(conn, :index, contributions: contributions)
  end

  def create(conn, %{"contribution" => contribution_params}) do
    # This should use create_pending_contribution for contributions without membership
    # or require membership_id in params for contributions with membership
    with {:ok, %Contribution{} = contribution} <- Contributions.create_pending_contribution(contribution_params) do
      conn
      |> put_status(:created)
      |> render(:show, contribution: contribution)
    end
  end

  def show(conn, %{"id" => id}) do
    contribution = Contributions.get_contribution!(id)
    render(conn, :show, contribution: contribution)
  end

  def update(conn, %{"id" => id, "contribution" => contribution_params}) do
    contribution = Contributions.get_contribution!(id)

    with {:ok, %Contribution{} = contribution} <- Contributions.update_contribution(contribution, contribution_params) do
      render(conn, :show, contribution: contribution)
    end
  end

  def delete(conn, %{"id" => id}) do
    contribution = Contributions.get_contribution!(id)

    with {:ok, %Contribution{}} <- Contributions.delete_contribution(contribution) do
      send_resp(conn, :no_content, "")
    end
  end
end
