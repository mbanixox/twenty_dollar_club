defmodule TwentyDollarClubWeb.UserController do
  @moduledoc """
  Handles user-related actions such as listing, creating, updating,
  and deleting users.
  """

  use TwentyDollarClubWeb, :controller

  alias TwentyDollarClub.{Users, Users.User}
  alias TwentyDollarClubWeb.{Auth.Guardian, Auth.ErrorResponse}

  import TwentyDollarClubWeb.Auth.AuthorizedPlug
  plug :is_authorized_user when action in [:update, :delete]

  action_fallback TwentyDollarClubWeb.FallbackController

  @doc """
  Lists all users.
  """
  def index(conn, _params) do
    users = Users.list_users()
    render(conn, :index, users: users)
  end

  @doc """
  Lists all users with their memberships.
  """
  def with_memberships(conn, _params) do
    users = Users.list_users_with_memberships()
    render(conn, :index, users: users)
  end

  @doc """
  Creates a new user without membership.
  User must complete payment to get membership.
  """
  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Users.create_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> render(:show, user: user, token: token)
    end
  end

  @doc """
  Authenticates a user and returns a session token.

  Expects `email` and `hashed_password` in the request body.
  """
  def sign_in(conn, %{"email" => email, "hashed_password" => hashed_password}) do
    authorize_user(conn, email, hashed_password)
  end

  # Helper function to authenticate a user and set session
  defp authorize_user(conn, email, hashed_password) do
    case Guardian.authenticate(email, hashed_password) do
      {:ok, user, token} ->
        # Ensure membership is preloaded
        user = TwentyDollarClub.Users.get_user_with_membership!(user.id)

        conn
        |> put_status(:ok)
        |> render(:show, user: user, token: token)

      {:error, :unauthorized} ->
        raise ErrorResponse.Unauthorized, message: "Invalid email or password"
    end
  end

  @doc """
  Refreshes the user's session token.

  Decodes and verifies the current token, then issues a new token if valid.
  """
  def refresh_session(conn, %{}) do
    token = Guardian.Plug.current_token(conn)
    {:ok, user, new_token} = Guardian.authenticate(token)

    conn
    |> put_status(:ok)
    |> render(:show, user: user, token: new_token)
  end

  @doc """
  Signs out the user and revokes their session token.

  Clears the session and returns the user with a `nil` token.
  """
  def sign_out(conn, %{}) do
    user = conn.assigns[:user]
    token = Guardian.Plug.current_token(conn)
    Guardian.revoke(token)

    conn
    |> put_status(:ok)
    |> render(:show, user: user, token: nil)
  end

  @doc """
  Shows a user by ID.
  """
  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, :show, user: user)
  end

  @doc """
  Updates a user's information.

  Expects `id` and user parameters in the request body.

  Only the account owner can update their information.
  """
  def update(conn, %{"user" => user_params}) do
    user = conn.assigns.user

    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  @doc """
  Deletes a user account.

  Expects `id` in the request body.
  """
  def delete(conn, _params) do
    user = conn.assigns.user

    with {:ok, %User{}} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
