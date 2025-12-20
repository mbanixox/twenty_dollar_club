defmodule TwentyDollarClubWeb.ContributionJSON do
  alias TwentyDollarClub.Contributions.Contribution

  @doc """
  Renders a list of contributions.
  """
  def index(%{contributions: contributions}) do
    %{data: for(contribution <- contributions, do: data(contribution))}
  end

  @doc """
  Renders a single contribution.
  """
  def show(%{contribution: contribution}) do
    %{data: data(contribution)}
  end

  defp data(%Contribution{} = contribution) do
    %{
      id: contribution.id,
      transaction_reference: contribution.transaction_reference,
      payment_method: contribution.payment_method
    }
  end
end
