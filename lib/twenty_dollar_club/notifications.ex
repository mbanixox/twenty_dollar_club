defmodule TwentyDollarClub.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias TwentyDollarClub.Repo

  alias TwentyDollarClub.Notifications.Notification

  @doc """
  Returns the list of notifications.

  ## Examples

      iex> list_notifications()
      [%Notification{}, ...]

  """
  def list_notifications do
    Repo.all(Notification)
  end

  def list_notifications_for_role(role, membership_id) do
    import Ecto.Query

    Notification
    |> where([n], n.recipient_type in ^recipient_types_for_role(role))
    |> where([n], n.membership_id == ^membership_id)
    |> Repo.all()
  end

  defp recipient_types_for_role(:admin), do: [:member, :admin]
  defp recipient_types_for_role(:super_admin), do: [:member, :admin, :super_admin]
  defp recipient_types_for_role(:member), do: [:member]
  defp recipient_types_for_role(_), do: []

  @doc """
  Gets a single notification.

  Raises `Ecto.NoResultsError` if the Notification does not exist.

  ## Examples

      iex> get_notification!(123)
      %Notification{}

      iex> get_notification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification!(id), do: Repo.get!(Notification, id)

  def get_notification_for_member!(id, membership_id) do
    Repo.get_by!(Notification, id: id, membership_id: membership_id)
  end

  @doc """
  Creates a notification.

  ## Examples

      iex> create_notification(%{field: value}, membership_id)
      {:ok, %Notification{}}

      iex> create_notification(%{field: bad_value}, membership_id)
      {:error, %Ecto.Changeset{}}

  """
  def create_notification(attrs, membership_id) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> put_change(:membership_id, membership_id)
    |> Repo.insert()
  end

  @doc """
  Updates a notification.

  ## Examples

      iex> update_notification(notification, %{field: new_value})
      {:ok, %Notification{}}

      iex> update_notification(notification, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification(%Notification{} = notification, attrs) do
    notification
    |> Notification.changeset(attrs)
    |> Repo.update()
  end

  def update_notification_read(%Notification{} = notification, attrs) do
    notification
    |> Notification.read_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a notification.

  ## Examples

      iex> delete_notification(notification)
      {:ok, %Notification{}}

      iex> delete_notification(notification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification(%Notification{} = notification) do
    Repo.delete(notification)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification changes.

  ## Examples

      iex> change_notification(notification)
      %Ecto.Changeset{data: %Notification{}}

  """
  def change_notification(%Notification{} = notification, attrs \\ %{}) do
    Notification.changeset(notification, attrs)
  end
end
