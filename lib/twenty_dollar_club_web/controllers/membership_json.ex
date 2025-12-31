defmodule TwentyDollarClubWeb.MembershipJSON do
  alias TwentyDollarClub.Memberships.Membership

  @doc """
  Renders a list of memberships.
  """
  def index(%{memberships: memberships}) do
    %{data: for(membership <- memberships, do: data(membership))}
  end

  @doc """
  Renders a single membership.
  """
  def show(%{membership: membership}) do
    %{data: data(membership)}
  end

  def data(%Membership{} = membership) do
    %{
      id: membership.id,
      generated_id: membership.generated_id,
      role: membership.role
    }
  end
end
