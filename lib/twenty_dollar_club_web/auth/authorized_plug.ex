defmodule TwentyDollarClubWeb.Auth.AuthorizedPlug do
  @moduledoc """
  Provides a plug for enforcing user authorization on sensitive actions.

  The `is_authorized/2` plug ensures that only the owner of a resource
  (such as a user account) can perform certain actions (like update or delete).

  ## How it works

  - For actions where the user ID is nested under `"user"` in the params (e.g., `update`):
    - Checks if `conn.assigns.user.id` matches `params["id"]`.
  - For actions where the user ID is at the top level in the params (e.g., `delete`):
    - Checks if `conn.assigns.user.id` matches `id`.

  If the IDs do not match, it raises a `Forbidden` error, preventing unauthorized access.

  ## Usage

      plug :is_authorized when action in [:update, :delete]

  This plug should be used in controllers to restrict access to actions that should only be performed by the resource owner.
  """

  alias TwentyDollarClubWeb.Auth.ErrorResponse

  def is_authorized(%{params: %{"user" => params}} = conn, _opts) do
    if conn.assigns.user.id == params["id"] do
      conn
    else
      raise ErrorResponse.Forbidden
    end
  end

  def is_authorized(%{params: %{"id" => id}} = conn, _opts) do
    if conn.assigns.user.id == id do
      conn
    else
      raise ErrorResponse.Forbidden
    end
  end


  def is_authorized(%{params: %{"membership" => params}} = conn, _opts) do
    if conn.assigns.user.membership.id == params["id"] do
      conn
    else
      raise ErrorResponse.Forbidden
    end
  end

  def is_authorized(%{params: %{"id" => id}} = conn, _opts) do
    if conn.assigns.user.membership.id == id do
      conn
    else
      raise ErrorResponse.Forbidden
    end
  end







end
