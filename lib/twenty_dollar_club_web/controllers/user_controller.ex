defmodule TwentyDollarClubWeb.UserController do
  use TwentyDollarClubWeb, :controller

  alias TwentyDollarClub.{Users, Users.User, Memberships, Memberships.Membership}
  alias TwentyDollarClubWeb.{Auth.Guardian, Auth.ErrorResponse}

  action_fallback TwentyDollarClubWeb.FallbackController

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

      {:error, :unauthorized} -> raise ErrorResponse.Unauthorized, message: "Invalid email or password"
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

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
