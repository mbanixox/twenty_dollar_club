defmodule TwentyDollarClub.BeneficiariesTest do
  use TwentyDollarClub.DataCase

  alias TwentyDollarClub.Beneficiaries

  describe "beneficiaries" do
    alias TwentyDollarClub.Beneficiaries.Beneficiary

    import TwentyDollarClub.BeneficiariesFixtures

    @invalid_attrs %{beneficiary_name: nil, relationship: nil}

    test "list_beneficiaries/0 returns all beneficiaries" do
      beneficiary = beneficiary_fixture()
      assert Beneficiaries.list_beneficiaries() == [beneficiary]
    end

    test "get_beneficiary!/1 returns the beneficiary with given id" do
      beneficiary = beneficiary_fixture()
      assert Beneficiaries.get_beneficiary!(beneficiary.id) == beneficiary
    end

    test "create_beneficiary/1 with valid data creates a beneficiary" do
      valid_attrs = %{beneficiary_name: "some beneficiary_name", relationship: "some relationship"}

      assert {:ok, %Beneficiary{} = beneficiary} = Beneficiaries.create_beneficiary(valid_attrs)
      assert beneficiary.beneficiary_name == "some beneficiary_name"
      assert beneficiary.relationship == "some relationship"
    end

    test "create_beneficiary/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Beneficiaries.create_beneficiary(@invalid_attrs)
    end

    test "update_beneficiary/2 with valid data updates the beneficiary" do
      beneficiary = beneficiary_fixture()
      update_attrs = %{beneficiary_name: "some updated beneficiary_name", relationship: "some updated relationship"}

      assert {:ok, %Beneficiary{} = beneficiary} = Beneficiaries.update_beneficiary(beneficiary, update_attrs)
      assert beneficiary.beneficiary_name == "some updated beneficiary_name"
      assert beneficiary.relationship == "some updated relationship"
    end

    test "update_beneficiary/2 with invalid data returns error changeset" do
      beneficiary = beneficiary_fixture()
      assert {:error, %Ecto.Changeset{}} = Beneficiaries.update_beneficiary(beneficiary, @invalid_attrs)
      assert beneficiary == Beneficiaries.get_beneficiary!(beneficiary.id)
    end

    test "delete_beneficiary/1 deletes the beneficiary" do
      beneficiary = beneficiary_fixture()
      assert {:ok, %Beneficiary{}} = Beneficiaries.delete_beneficiary(beneficiary)
      assert_raise Ecto.NoResultsError, fn -> Beneficiaries.get_beneficiary!(beneficiary.id) end
    end

    test "change_beneficiary/1 returns a beneficiary changeset" do
      beneficiary = beneficiary_fixture()
      assert %Ecto.Changeset{} = Beneficiaries.change_beneficiary(beneficiary)
    end
  end
end
