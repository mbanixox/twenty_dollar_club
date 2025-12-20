defmodule TwentyDollarClubWeb.ContributionControllerTest do
  use TwentyDollarClubWeb.ConnCase

  import TwentyDollarClub.ContributionsFixtures
  alias TwentyDollarClub.Contributions.Contribution

  @create_attrs %{
    transaction_reference: "some transaction_reference",
    payment_method: "some payment_method"
  }
  @update_attrs %{
    transaction_reference: "some updated transaction_reference",
    payment_method: "some updated payment_method"
  }
  @invalid_attrs %{transaction_reference: nil, payment_method: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all contributions", %{conn: conn} do
      conn = get(conn, ~p"/api/contributions")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create contribution" do
    test "renders contribution when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/contributions", contribution: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/contributions/#{id}")

      assert %{
               "id" => ^id,
               "payment_method" => "some payment_method",
               "transaction_reference" => "some transaction_reference"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/contributions", contribution: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update contribution" do
    setup [:create_contribution]

    test "renders contribution when data is valid", %{conn: conn, contribution: %Contribution{id: id} = contribution} do
      conn = put(conn, ~p"/api/contributions/#{contribution}", contribution: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/contributions/#{id}")

      assert %{
               "id" => ^id,
               "payment_method" => "some updated payment_method",
               "transaction_reference" => "some updated transaction_reference"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, contribution: contribution} do
      conn = put(conn, ~p"/api/contributions/#{contribution}", contribution: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete contribution" do
    setup [:create_contribution]

    test "deletes chosen contribution", %{conn: conn, contribution: contribution} do
      conn = delete(conn, ~p"/api/contributions/#{contribution}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/contributions/#{contribution}")
      end
    end
  end

  defp create_contribution(_) do
    contribution = contribution_fixture()

    %{contribution: contribution}
  end
end
