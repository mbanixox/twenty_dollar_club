defmodule TwentyDollarClubWeb.ProjectContributionJSON do
  alias TwentyDollarClub.ProjectContributions.ProjectContribution

  @doc """
  Renders a list of project_contributions.
  """
  def index(%{project_contributions: project_contributions}) do
    %{data: for(project_contribution <- project_contributions, do: data(project_contribution))}
  end

  @doc """
  Renders a single project_contribution.
  """
  def show(%{project_contribution: project_contribution}) do
    %{data: data(project_contribution)}
  end

  defp data(%ProjectContribution{} = project_contribution) do
    %{
      id: project_contribution.id,
      total_amount_funded: project_contribution.total_amount_funded,
      goal_amount: project_contribution.goal_amount
    }
  end
end
