defmodule TwentyDollarClubWeb.BeneficiaryController do
  use TwentyDollarClubWeb, :controller

  require Logger

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
    Logger.info("Listing beneficiaries for membership_id=#{membership_id}")
    render(conn, :index, beneficiaries: beneficiaries)
  end

  def create(conn, %{"beneficiary" => beneficiary_params}) do
    membership = conn.assigns.user.membership
    preloaded_membership = Memberships.get_membership_with_beneficiaries!(membership.id)
    membership_id = preloaded_membership.id

    case Beneficiaries.create_beneficiary(preloaded_membership, beneficiary_params) do
      {:ok, %Beneficiary{} = beneficiary} ->
        Logger.info("Created beneficiary id=#{beneficiary.id} for membership_id=#{membership_id}")
        conn
        |> put_status(:created)
        |> render(:show, beneficiary: beneficiary)

      {:error, changeset} ->
        Logger.error("Failed to create beneficiary for membership_id=#{membership_id}: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  end

  def show(conn, %{"id" => id}) do
    beneficiary = Beneficiaries.get_beneficiary!(id)
    Logger.info("Showing beneficiary id=#{id}")
    render(conn, :show, beneficiary: beneficiary)
  end

  def update(conn, %{"id" => id, "beneficiary" => beneficiary_params}) do
    beneficiary = Beneficiaries.get_beneficiary!(id)

    case Beneficiaries.update_beneficiary(beneficiary, beneficiary_params) do
      {:ok, %Beneficiary{} = updated_beneficiary} ->
        Logger.info("Updated beneficiary id=#{id}")
        render(conn, :show, beneficiary: updated_beneficiary)

      {:error, changeset} ->
        Logger.error("Failed to update beneficiary id=#{id}: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  end

  def delete(conn, %{"id" => id}) do
    beneficiary = Beneficiaries.get_beneficiary!(id)

    case Beneficiaries.delete_beneficiary(beneficiary) do
      {:ok, %Beneficiary{}} ->
        Logger.info("Deleted beneficiary id=#{id}")
        send_resp(conn, :no_content, "")

      {:error, changeset} ->
        Logger.error("Failed to delete beneficiary id=#{id}: #{inspect(changeset.errors)}")
        {:error, changeset}
    end
  end
end
