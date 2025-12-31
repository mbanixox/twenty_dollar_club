defmodule TwentyDollarClubWeb.UserJSON do
  alias TwentyDollarClub.Users.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user, token: token}) do
    %{
      data: data(user),
      token: token
    }
  end

  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      phone_number: user.phone_number,
      gender: user.gender,
      membership:
        case user.membership do
          nil -> nil
          membership -> TwentyDollarClubWeb.MembershipJSON.data(membership)
        end
    }
  end
end
