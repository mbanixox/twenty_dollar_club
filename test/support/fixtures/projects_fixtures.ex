defmodule TwentyDollarClub.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TwentyDollarClub.Projects` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        description: "some description",
        funded_amount: "120.5",
        goal_amount: "120.5",
        status: "some status",
        title: "some title"
      })
      |> TwentyDollarClub.Projects.create_project()

    project
  end
end
