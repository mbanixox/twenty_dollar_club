defmodule TwentyDollarClub.ContributionsTest do
  use TwentyDollarClub.DataCase

  alias TwentyDollarClub.Contributions

  describe "contributions" do
    alias TwentyDollarClub.Contributions.Contribution

    import TwentyDollarClub.ContributionsFixtures

    @invalid_attrs %{transaction_reference: nil, payment_method: nil}

    test "list_contributions/0 returns all contributions" do
      contribution = contribution_fixture()
      assert Contributions.list_contributions() == [contribution]
    end

    test "get_contribution!/1 returns the contribution with given id" do
      contribution = contribution_fixture()
      assert Contributions.get_contribution!(contribution.id) == contribution
    end

    test "create_contribution/1 with valid data creates a contribution" do
      valid_attrs = %{transaction_reference: "some transaction_reference", payment_method: "some payment_method"}

      assert {:ok, %Contribution{} = contribution} = Contributions.create_contribution(valid_attrs)
      assert contribution.transaction_reference == "some transaction_reference"
      assert contribution.payment_method == "some payment_method"
    end

    test "create_contribution/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contributions.create_contribution(@invalid_attrs)
    end

    test "update_contribution/2 with valid data updates the contribution" do
      contribution = contribution_fixture()
      update_attrs = %{transaction_reference: "some updated transaction_reference", payment_method: "some updated payment_method"}

      assert {:ok, %Contribution{} = contribution} = Contributions.update_contribution(contribution, update_attrs)
      assert contribution.transaction_reference == "some updated transaction_reference"
      assert contribution.payment_method == "some updated payment_method"
    end

    test "update_contribution/2 with invalid data returns error changeset" do
      contribution = contribution_fixture()
      assert {:error, %Ecto.Changeset{}} = Contributions.update_contribution(contribution, @invalid_attrs)
      assert contribution == Contributions.get_contribution!(contribution.id)
    end

    test "delete_contribution/1 deletes the contribution" do
      contribution = contribution_fixture()
      assert {:ok, %Contribution{}} = Contributions.delete_contribution(contribution)
      assert_raise Ecto.NoResultsError, fn -> Contributions.get_contribution!(contribution.id) end
    end

    test "change_contribution/1 returns a contribution changeset" do
      contribution = contribution_fixture()
      assert %Ecto.Changeset{} = Contributions.change_contribution(contribution)
    end
  end
end
