defmodule TwentyDollarClub.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TwentyDollarClub.Users` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        first_name: "some first_name",
        gender: "some gender",
        last_name: "some last_name",
        phone_number: "some phone_number"
      })
      |> TwentyDollarClub.Users.create_user()

    user
  end
end
