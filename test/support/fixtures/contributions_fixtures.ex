defmodule TwentyDollarClub.ContributionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TwentyDollarClub.Contributions` context.
  """

  @doc """
  Generate a contribution.
  """
  def contribution_fixture(attrs \\ %{}) do
    {:ok, contribution} =
      attrs
      |> Enum.into(%{
        payment_method: "some payment_method",
        transaction_reference: "some transaction_reference"
      })
      |> TwentyDollarClub.Contributions.create_contribution()

    contribution
  end
end
