defmodule TwentyDollarClubWeb.Auth.SetAdmin do
  @moduledoc """
  Plug to ensure the current user has admin privileges.

  ## Usage

  Add this plug to a pipeline or controller to restrict access to
  admin-only routes.
  Both `:admin` and `:super_admin` roles are permitted.

  ## Behavior

  - If the user is already assigned as `:admin`, the plug does nothing.
  - If the user is not present, has no membership, or their role
    is not `:admin` or `:super_admin`, it raises `ErrorResponse.Unauthorized`.
  - Otherwise, assigns `:admin` to the connection.
  """

  import Plug.Conn

  alias TwentyDollarClubWeb.Auth.ErrorResponse

  def init(_options) do
  end

  def call(conn, _options) do
    if conn.assigns[:admin] do
      conn
    else
      user = conn.assigns[:user]

      if user == nil or user.membership == nil or
         not (user.membership.role in [:admin, :super_admin]) do
        raise ErrorResponse.Unauthorized
      end

      assign(conn, :admin, user.membership)
    end
  end
end
