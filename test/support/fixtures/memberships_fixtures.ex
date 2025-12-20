defmodule TwentyDollarClub.MembershipsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TwentyDollarClub.Memberships` context.
  """

  @doc """
  Generate a membership.
  """
  def membership_fixture(attrs \\ %{}) do
    {:ok, membership} =
      attrs
      |> Enum.into(%{
        generated_id: 42,
        role: "some role"
      })
      |> TwentyDollarClub.Memberships.create_membership()

    membership
  end
end
