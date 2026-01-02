defmodule TwentyDollarClub.Memberships do
  @moduledoc """
  The Memberships context.
  """

  import Ecto.Query, warn: false
  alias TwentyDollarClub.Repo
  alias TwentyDollarClub.Memberships.Membership

  @doc """
  Returns the list of memberships.

  ## Examples

      iex> list_memberships()
      [%Membership{}, ...]

  """
  def list_memberships do
    Repo.all(Membership)
  end

  @doc """
  Gets a single membership.

  Raises `Ecto.NoResultsError` if the Membership does not exist.

  ## Examples

      iex> get_membership!(123)
      %Membership{}

      iex> get_membership!(456)
      ** (Ecto.NoResultsError)

  """
  def get_membership!(id), do: Repo.get!(Membership, id)

  @doc """
  Gets a single membership preloaded with beneficiaries.

  Raises `Ecto.NoResultsError` if the Membership does not exist.

  ## Examples

      iex> get_membership_with_beneficiaries!(123)
      %Membership{beneficiaries: [%Beneficiary{}, ...]}

  """
  def get_membership_with_beneficiaries!(id) do
    Membership
    |> Repo.get!(id)
    |> Repo.preload(:beneficiaries)
  end

  @doc """
  Creates a membership.

  ## Examples

      iex> create_membership(%{field: value})
      {:ok, %Membership{}}

      iex> create_membership(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_membership(user, attrs) do
    membership_attrs =
      attrs
      |> Map.put_new("role", "member")

    user
    |> Ecto.build_assoc(:membership)
    |> Membership.changeset(membership_attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a membership.

  ## Examples

      iex> update_membership(membership, %{field: new_value})
      {:ok, %Membership{}}

      iex> update_membership(membership, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_membership(%Membership{} = membership, attrs) do
    membership
    |> Membership.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a membership.

  ## Examples

      iex> delete_membership(membership)
      {:ok, %Membership{}}

      iex> delete_membership(membership)
      {:error, %Ecto.Changeset{}}

  """
  def delete_membership(%Membership{} = membership) do
    Repo.delete(membership)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking membership changes.

  ## Examples

      iex> change_membership(membership)
      %Ecto.Changeset{data: %Membership{}}

  """
  def change_membership(%Membership{} = membership, attrs \\ %{}) do
    Membership.changeset(membership, attrs)
  end
end
