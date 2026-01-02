defmodule TwentyDollarClubWeb.Auth.AuthorizedPlug do
  @moduledoc """
  Provides plugs for enforcing user, member, and admin authorization on sensitive actions.

  ## Functions

  - `is_authorized_user/2`:
    Ensures that only the owner of a user resource can perform certain actions (like update or delete).
    - If the user ID is nested under `"user"` in the params (e.g., `update`), checks if `conn.assigns.user.id` matches `params["id"]`.
    - If the user ID is at the top level in the params (e.g., `delete`), checks if `conn.assigns.user.id` matches `id`.
    - Raises `Forbidden` if the IDs do not match.

  - `is_authorized_member/2`:
    Ensures that only the owner of a membership resource can perform certain actions.
    - If the membership ID is nested under `"membership"` in the params, checks if `conn.assigns.user.membership.id` matches `params["id"]`.
    - If the membership ID is at the top level in the params, checks if `conn.assigns.user.membership.id` matches `id`.
    - Raises `Forbidden` if the IDs do not match.

  - `is_authorized_member_with_beneficiaries/2`:
    Ensures that only the member who owns a beneficiary can access or modify it.
    - Loads the current user's membership with preloaded beneficiaries.
    - Extracts the beneficiary ID from params.
    - Checks if the beneficiary ID belongs to the current user's membership.
    - Raises `Forbidden` if the beneficiary does not belong to the member.

  - `is_authorized_admin/2`:
    Ensures that only users with the admin role can perform admin-level actions.
    - Checks if `conn.assigns.user.membership.role == :admin`.
    - Raises `Forbidden` if the user is not an admin.

  ## Usage

      plug :is_authorized_user when action in [:update, :delete]
      plug :is_authorized_member when action in [:delete]
      plug :is_authorized_member_with_beneficiaries when action in [:show, :update, :delete]
      plug :is_authorized_admin when action in [:update]

  Use these plugs in controllers to restrict access to actions that should only be performed by the resource owner, beneficiary owner, or an admin.
  """

  alias TwentyDollarClubWeb.Auth.ErrorResponse

  def is_authorized_user(%{params: %{"user" => params}} = conn, _opts) do
    if conn.assigns.user.id == params["id"] do
      conn
    else
      raise ErrorResponse.Forbidden
    end
  end

  def is_authorized_user(%{params: %{"id" => id}} = conn, _opts) do
    if conn.assigns.user.id == id do
      conn
    else
      raise ErrorResponse.Forbidden
    end
  end

  def is_authorized_member(%{params: %{"membership" => params}} = conn, _opts) do
    if conn.assigns.user.membership.id == params["id"] do
      conn
    else
      raise ErrorResponse.Forbidden
    end
  end

  def is_authorized_member(%{params: %{"id" => id}} = conn, _opts) do
    if conn.assigns.user.membership.id == id do
      conn
    else
      raise ErrorResponse.Forbidden
    end
  end

  def is_authorized_member_with_beneficiaries(conn, _opts) do
    membership =
      TwentyDollarClub.Memberships.get_membership_with_beneficiaries!(conn.assigns.user.membership.id)

    beneficiary_id =
      case conn.params do
        %{"id" => id} -> id
        %{"beneficiary" => %{"id" => id}} -> id
        _ -> nil
      end

    if Enum.any?(membership.beneficiaries, fn b -> to_string(b.id) == to_string(beneficiary_id) end) do
      conn
    else
      raise TwentyDollarClubWeb.Auth.ErrorResponse.Forbidden
    end
  end

  def is_authorized_admin(conn, _opts) do
    if conn.assigns.user.membership.role == :admin do
      conn
    else
      raise ErrorResponse.Forbidden
    end
  end
end
