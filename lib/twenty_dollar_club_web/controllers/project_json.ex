defmodule TwentyDollarClubWeb.ProjectJSON do
  alias TwentyDollarClub.Projects.Project

  @doc """
  Renders a list of projects.
  """
  def index(%{projects: projects}) do
    %{data: for(project <- projects, do: data(project))}
  end

  @doc """
  Renders a single project.
  """
  def show(%{project: project}) do
    %{data: data(project)}
  end

  defp data(%Project{} = project) do
    %{
      id: project.id,
      title: project.title,
      description: project.description,
      status: project.status,
      goal_amount: project.goal_amount,
      funded_amount: project.funded_amount
    }
  end
end
