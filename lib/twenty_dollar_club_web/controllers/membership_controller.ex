defmodule TwentyDollarClubWeb.MembershipController do
  @moduledoc """
  Controller for managing memberships.

  ## Actions

    * `index/2` - Lists all memberships.
    * `show/2` - Shows a membership by ID.
    * `update/2` - Updates a membership's role, enforcing role update rules.
    * `delete/2` - Deletes a membership.

  ## Authorization

    * `:is_authorized_member` plug is used for delete actions.
    * `:is_authorized_admin` plug is used for update actions.

  ## Role Update Rules

    * Admins can update a membership from `member` to `admin`.
    * Super admins can update a membership from `member` to `admin` or `super_admin`.
    * Admins cannot update to `super_admin`.

  See `Membership.allowed_role_update?/2` for details.
  """

  use TwentyDollarClubWeb, :controller

  alias TwentyDollarClub.Memberships
  alias TwentyDollarClub.Memberships.Membership

  import TwentyDollarClubWeb.Auth.AuthorizedPlug
  plug :is_authorized_member when action in [:delete]
  plug :is_authorized_admin when action in [:update]

  action_fallback TwentyDollarClubWeb.FallbackController

  @doc """
  Lists all memberships.
  """
  def index(conn, _params) do
    memberships = Memberships.list_memberships()
    render(conn, :index, memberships: memberships)
  end

  @doc """
  Shows a membership by ID.
  """
  def show(conn, %{"id" => id}) do
    membership = Memberships.get_membership!(id)
    render(conn, :show, membership: membership)
  end

  @doc """
  Updates a membership's role if allowed by the current user's role.

  Returns forbidden if the role update is not permitted.
  """
  def update(conn, %{"membership" => %{"role" => new_role} = membership_params}) do
    membership = conn.assigns.user.membership
    current_role = membership.role

    if Membership.allowed_role_update?(current_role, String.to_existing_atom(new_role)) do
      with {:ok, %Membership{} = membership} <-
             Memberships.update_membership(membership, membership_params) do
        render(conn, :show, membership: membership)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "You are not allowed to update to this role"})
    end
  end

  @doc """
  Deletes a membership.
  """
  def delete(conn, _params) do
    membership = conn.assigns.user.membership

    with {:ok, %Membership{}} <- Memberships.delete_membership(membership) do
      send_resp(conn, :no_content, "")
    end
  end
end
