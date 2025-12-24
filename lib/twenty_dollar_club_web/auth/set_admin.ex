defmodule TwentyDollarClubWeb.Auth.SetAdmin do

  import Plug.Conn

  alias TwentyDollarClubWeb.Auth.ErrorResponse
  alias TwentyDollarClub.Memberships



  def init(_options) do
  end



  def call(conn, _options) do
    if conn.assigns[:admin] do
      conn
    else
      membership_id = get_session(conn, :membership_id)

      if membership_id == nil, do: raise(ErrorResponse.Unauthorized)

      membership = Memberships.get_membership!(membership_id)
      is_admin = membership.role == :admin

      cond do
        membership_id && membership && is_admin ->
          assign(conn, :admin, membership)

        true ->
          assign(conn, :admin, nil)
      end
    end
  end
end
