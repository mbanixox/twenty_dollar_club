defmodule TwentyDollarClubWeb.UserController do
  @moduledoc """
  Handles user-related actions such as listing, creating, updating,
  and deleting users.

  ## Authorization

  The `is_authorized_account/2` plug is used to ensure that only the
  owner of an account can update or delete their user record.

  ### How `is_authorized_account/2` Works

  - This plug is invoked before the `update` and `delete` actions.
  - It fetches the user from the database using the `id` provided in
    the request parameters.
  - It compares the `id` of the currently authenticated user
    (from `conn.assigns.user`) with the `id` of the user being accessed.
  - If the IDs match, the request proceeds.
  - If they do not match, it raises a `Forbidden` error, preventing
    unauthorized access.

  This ensures that users can only modify or delete their own accounts.
  """

  use TwentyDollarClubWeb, :controller

  alias TwentyDollarClub.{Users, Users.User, Memberships, Memberships.Membership}
  alias TwentyDollarClubWeb.{Auth.Guardian, Auth.ErrorResponse}

  plug :is_authorized_account when action in [:update, :delete]

  action_fallback TwentyDollarClubWeb.FallbackController

  defp is_authorized_account(conn, _opts) do
    user_id =
      case conn.params do
        %{"user" => %{"id" => id}} -> id
        %{"id" => id} -> id
      end

    user = Users.get_user!(user_id)

    if conn.assigns.user.id == user.id do
      conn
    else
      raise ErrorResponse.Forbidden
    end
  end

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Users.create_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user),
         {:ok, %Membership{} = _membership} <- Memberships.create_membership(user, user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, user: user, token: token)
    end
  end

  def sign_in(conn, %{"email" => email, "hashed_password" => hashed_password}) do
    case Guardian.authenticate(email, hashed_password) do
      {:ok, user, token} ->
        conn
        |> Plug.Conn.put_session(:user_id, user.id)
        |> put_status(:ok)
        |> render(:show, user: user, token: token)

      {:error, :unauthorized} ->
        raise ErrorResponse.Unauthorized, message: "Invalid email or password"
    end
  end

  def sign_out(conn, %{}) do
    user = conn.assigns[:user]
    token = Guardian.Plug.current_token(conn)
    Guardian.revoke(token)

    conn
    |> Plug.Conn.clear_session()
    |> put_status(:ok)
    |> render(:show, user: user, token: nil)
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"user" => user_params}) do
    user = Users.get_user!(user_params["id"])

    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    with {:ok, %User{}} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
