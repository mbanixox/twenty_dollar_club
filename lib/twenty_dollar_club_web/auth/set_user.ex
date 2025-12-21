defmodule TwentyDollarClubWeb.Auth.SetUser do
  @moduledoc """
  Assigns the current user to the connection if a user session exists.

  If the user is not found in the session, it raises an unauthorized error.
  """

  import Plug.Conn

  alias TwentyDollarClubWeb.Auth.ErrorResponse
  alias TwentyDollarClub.Users

  @doc """
  Initializes options for the plug. No options are used.
  """
  def init(_options) do
  end

  @doc """
  Assigns the user to the connection if a valid `:user_id` is found in the session.

  Raises `ErrorResponse.Unauthorized` if no user is found in the session.
  """
  def call(conn, _options) do
    if conn.assigns[:user] do
      conn

    else
      user_id = get_session(conn, :user_id)

      if user_id == nil, do: raise(ErrorResponse.Unauthorized)

      user = Users.get_user!(user_id)

      cond do
        user_id && user ->
          assign(conn, :user, user)

        true ->
          assign(conn, :user, nil)
      end
    end
  end
end
