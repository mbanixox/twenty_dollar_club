defmodule TwentyDollarClubWeb.Auth.SetMembership do
  @moduledoc """
  Assigns the current membership to the connection if a membership session exists.

  If the membership is not found in the session, it raises an unauthorized error.
  """

  import Plug.Conn

  alias TwentyDollarClubWeb.Auth.ErrorResponse
  alias TwentyDollarClub.Memberships

  @doc """
  Initializes options for the plug. No options are used.
  """
  def init(_options) do
  end

  @doc """
  Assigns the member to the connection if a valid `:membership_id` is found in the session.

  Raises `ErrorResponse.Unauthorized` if no membership is found in the session.
  """
  def call(conn, _options) do
    if conn.assigns[:membership] do
      conn
    else
      membership_id = get_session(conn, :membership_id)

      if membership_id == nil, do: raise(ErrorResponse.Unauthorized)

      membership = Memberships.get_membership!(membership_id)

      cond do
        membership_id && membership ->
          assign(conn, :membership, membership)

        true ->
          assign(conn, :membership, nil)
      end
    end
  end
end
