defmodule TwentyDollarClub.ProjectContributionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TwentyDollarClub.ProjectContributions` context.
  """

  @doc """
  Generate a project_contribution.
  """
  def project_contribution_fixture(attrs \\ %{}) do
    {:ok, project_contribution} =
      attrs
      |> Enum.into(%{
        goal_amount: "120.5",
        total_amount_funded: "120.5"
      })
      |> TwentyDollarClub.ProjectContributions.create_project_contribution()

    project_contribution
  end
end
