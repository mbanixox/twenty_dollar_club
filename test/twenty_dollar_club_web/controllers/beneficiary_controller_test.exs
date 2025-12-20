defmodule TwentyDollarClubWeb.BeneficiaryControllerTest do
  use TwentyDollarClubWeb.ConnCase

  import TwentyDollarClub.BeneficiariesFixtures
  alias TwentyDollarClub.Beneficiaries.Beneficiary

  @create_attrs %{
    beneficiary_name: "some beneficiary_name",
    relationship: "some relationship"
  }
  @update_attrs %{
    beneficiary_name: "some updated beneficiary_name",
    relationship: "some updated relationship"
  }
  @invalid_attrs %{beneficiary_name: nil, relationship: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all beneficiaries", %{conn: conn} do
      conn = get(conn, ~p"/api/beneficiaries")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create beneficiary" do
    test "renders beneficiary when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/beneficiaries", beneficiary: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/beneficiaries/#{id}")

      assert %{
               "id" => ^id,
               "beneficiary_name" => "some beneficiary_name",
               "relationship" => "some relationship"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/beneficiaries", beneficiary: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update beneficiary" do
    setup [:create_beneficiary]

    test "renders beneficiary when data is valid", %{conn: conn, beneficiary: %Beneficiary{id: id} = beneficiary} do
      conn = put(conn, ~p"/api/beneficiaries/#{beneficiary}", beneficiary: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/beneficiaries/#{id}")

      assert %{
               "id" => ^id,
               "beneficiary_name" => "some updated beneficiary_name",
               "relationship" => "some updated relationship"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, beneficiary: beneficiary} do
      conn = put(conn, ~p"/api/beneficiaries/#{beneficiary}", beneficiary: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete beneficiary" do
    setup [:create_beneficiary]

    test "deletes chosen beneficiary", %{conn: conn, beneficiary: beneficiary} do
      conn = delete(conn, ~p"/api/beneficiaries/#{beneficiary}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/beneficiaries/#{beneficiary}")
      end
    end
  end

  defp create_beneficiary(_) do
    beneficiary = beneficiary_fixture()

    %{beneficiary: beneficiary}
  end
end
