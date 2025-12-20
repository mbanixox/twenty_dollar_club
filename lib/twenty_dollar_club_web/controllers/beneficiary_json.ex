defmodule TwentyDollarClubWeb.BeneficiaryJSON do
  alias TwentyDollarClub.Beneficiaries.Beneficiary

  @doc """
  Renders a list of beneficiaries.
  """
  def index(%{beneficiaries: beneficiaries}) do
    %{data: for(beneficiary <- beneficiaries, do: data(beneficiary))}
  end

  @doc """
  Renders a single beneficiary.
  """
  def show(%{beneficiary: beneficiary}) do
    %{data: data(beneficiary)}
  end

  defp data(%Beneficiary{} = beneficiary) do
    %{
      id: beneficiary.id,
      beneficiary_name: beneficiary.beneficiary_name,
      relationship: beneficiary.relationship
    }
  end
end
