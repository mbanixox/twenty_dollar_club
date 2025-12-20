defmodule TwentyDollarClub.BeneficiariesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TwentyDollarClub.Beneficiaries` context.
  """

  @doc """
  Generate a beneficiary.
  """
  def beneficiary_fixture(attrs \\ %{}) do
    {:ok, beneficiary} =
      attrs
      |> Enum.into(%{
        beneficiary_name: "some beneficiary_name",
        relationship: "some relationship"
      })
      |> TwentyDollarClub.Beneficiaries.create_beneficiary()

    beneficiary
  end
end
