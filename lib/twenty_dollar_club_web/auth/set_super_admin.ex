defmodule TwentyDollarClubWeb.Auth.SetSuperAdmin do
  import Plug.Conn

  alias TwentyDollarClubWeb.Auth.ErrorResponse

  def init(_options) do
  end

  def call(conn, _options) do
    if conn.assigns[:super_admin] do
      conn
    else
      user = conn.assigns[:user]

      if user == nil or user.membership == nil or user.membership.role != :super_admin do
        raise ErrorResponse.Unauthorized
      end

      assign(conn, :super_admin, user.membership)
    end
  end
end
