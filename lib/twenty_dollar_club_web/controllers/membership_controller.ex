defmodule TwentyDollarClubWeb.MembershipController do
  use TwentyDollarClubWeb, :controller

  alias TwentyDollarClub.Memberships
  alias TwentyDollarClub.Memberships.Membership

  import TwentyDollarClubWeb.Auth.AuthorizedPlug
  plug :is_authorized_member when action in [:delete]
  plug :is_authorized_admin when action in [:update]

  action_fallback TwentyDollarClubWeb.FallbackController

  def index(conn, _params) do
    memberships = Memberships.list_memberships()
    render(conn, :index, memberships: memberships)
  end

  # def create(conn, %{"membership" => membership_params}) do
  #   with {:ok, %Membership{} = membership} <- Memberships.create_membership(membership_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", ~p"/api/memberships/#{membership}")
  #     |> render(:show, membership: membership)
  #   end
  # end

  def show(conn, %{"id" => id}) do
    membership = Memberships.get_membership!(id)
    render(conn, :show, membership: membership)
  end

  def update(conn, %{"membership" => membership_params}) do
    membership = conn.assigns.user.membership

    with {:ok, %Membership{} = membership} <-
           Memberships.update_membership(membership, membership_params) do
      render(conn, :show, membership: membership)
    end
  end

  def delete(conn, _params) do
    membership = conn.assigns.user.membership

    with {:ok, %Membership{}} <- Memberships.delete_membership(membership) do
      send_resp(conn, :no_content, "")
    end
  end
end
