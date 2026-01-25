defmodule TwentyDollarClub.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false

  alias TwentyDollarClub.Repo
  alias TwentyDollarClub.Users.User

  require Logger

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  def list_pending_users do
    from(u in User,
      where: u.membership_status == ^:pending
    )
    |> Repo.all()
  end

  def activate_user_membership(user_id) do
    user = get_user!(user_id)

    user
    |> User.changeset(%{membership_status: :active})
    |> Repo.update()
  end

  def get_membership_status(user_id) do
    user = get_user!(user_id)
    {:ok, user.membership_status}
  end

  def approve_user_membership(user_id) do
    user = get_user!(user_id)

    user
    |> User.changeset(%{membership_status: :approved})
    |> Repo.update()
  end

  def reject_user_membership(user_id) do
    user = get_user!(user_id)

    user
    |> User.changeset(%{membership_status: :rejected})
    |> Repo.update()
  end

  def list_users_with_memberships do
    from(u in User,
      join: m in assoc(u, :membership),
      preload: [membership: m]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user_with_membership!(id) do
    User
    |> where(id: ^id)
    |> preload(:membership)
    |> Repo.one!()
  end

  @doc """
  Gets a single user by email.

  Returns 'nil' if the User does not exist.

  ## Examples

      iex> get_user_by_email(test@test.com)
      %User{}

      iex> get_user_by_email(nonexistent@test.com)
      nil

  """
  def get_user_by_email(email) do
    User
    |> where(email: ^email)
    |> Repo.one()
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def validate_no_membership(user) do
    user = Repo.preload(user, :membership)

    case user.membership do
      nil ->
        Logger.debug("User has no active membership")
        {:ok, user}
      _membership ->
        Logger.warning("User already has an active membership")
        {:error, :already_has_membership}
    end
  end

end
