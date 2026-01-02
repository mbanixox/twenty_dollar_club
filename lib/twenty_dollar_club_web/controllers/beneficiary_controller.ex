defmodule TwentyDollarClubWeb.BeneficiaryController do
  use TwentyDollarClubWeb, :controller

  alias TwentyDollarClub.Beneficiaries
  alias TwentyDollarClub.Beneficiaries.Beneficiary
  alias TwentyDollarClub.Memberships

  action_fallback TwentyDollarClubWeb.FallbackController

  import TwentyDollarClubWeb.Auth.AuthorizedPlug
  plug :is_authorized_member_with_beneficiaries when action in [:show, :update, :delete]

  # Only show beneficiaries belonging to the current member
  def index(conn, _params) do
    membership_id = conn.assigns.user.membership.id
    members = Memberships.get_membership_with_beneficiaries!(membership_id)
    beneficiaries = members.beneficiaries
    render(conn, :index, beneficiaries: beneficiaries)
  end

  def create(conn, %{"beneficiary" => beneficiary_params}) do
    with {:ok, %Beneficiary{} = beneficiary} <- Beneficiaries.create_beneficiary(beneficiary_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/beneficiaries/#{beneficiary}")
      |> render(:show, beneficiary: beneficiary)
    end
  end

  def show(conn, %{"id" => id}) do
    beneficiary = Beneficiaries.get_beneficiary!(id)
    render(conn, :show, beneficiary: beneficiary)
  end

  def update(conn, %{"id" => id, "beneficiary" => beneficiary_params}) do
    beneficiary = Beneficiaries.get_beneficiary!(id)

    with {:ok, %Beneficiary{} = beneficiary} <- Beneficiaries.update_beneficiary(beneficiary, beneficiary_params) do
      render(conn, :show, beneficiary: beneficiary)
    end
  end

  def delete(conn, %{"id" => id}) do
    beneficiary = Beneficiaries.get_beneficiary!(id)

    with {:ok, %Beneficiary{}} <- Beneficiaries.delete_beneficiary(beneficiary) do
      send_resp(conn, :no_content, "")
    end
  end
end
