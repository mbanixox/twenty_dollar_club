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
    Notification
    |> where([n], n.recipient_type in ^recipient_types_for_role(role))
    |> where([n], n.membership_id == ^membership_id)
    |> order_by([n], desc: n.inserted_at)
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
  Gets the count of unread notifications for a membership
  """
  def get_unread_notifications_count(membership_id) do
    Notification
    |> where([n], n.membership_id == ^membership_id and n.read == false)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Creates a notification and broadcasts it to the user's channel

  ## Examples

      iex> create_notification(%{field: value}, membership_id)
      {:ok, %Notification{}}

      iex> create_notification(%{field: bad_value}, membership_id)
      {:error, %Ecto.Changeset{}}

  """
  def create_notification(attrs, membership_id) do
    result =
      %Notification{}
      |> Notification.changeset(attrs)
      |> put_change(:membership_id, membership_id)
      |> Repo.insert()

    case result do
      {:ok, notification} ->
        # Broadcast new notification to the user's channel
        Phoenix.PubSub.broadcast(
          TwentyDollarClub.PubSub,
          "notifications:#{notification.membership_id}",
          {:new_notification, notification}
        )

        {:ok, notification}

      error ->
        error
    end
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

  @doc """
  Updates a notification's read status and broadcasts count update
  """
  def update_notification_read(%Notification{} = notification, attrs) do
    result =
      notification
      |> Notification.read_changeset(attrs)
      |> Repo.update()

    case result do
      {:ok, updated_notification} ->
        # Broadcast updated unread count to user's channel
        Phoenix.PubSub.broadcast(
          TwentyDollarClub.PubSub,
          "notifications:#{updated_notification.membership_id}",
          :unread_count
        )

        {:ok, updated_notification}

      error ->
        error
    end
  end

  @doc """
  Marks a notification as read by ID
  """
  def mark_as_read(notification_id) do
    notification = Repo.get!(Notification, notification_id)
    update_notification_read(notification, %{read: true})
  end

  @doc """
  Marks a notification as unread by ID
  """
  def mark_as_unread(notification_id) do
    notification = Repo.get!(Notification, notification_id)
    update_notification_read(notification, %{read: false})
  end

  @doc """
  Deletes a notification and broadcasts count update

  ## Examples

      iex> delete_notification(notification)
      {:ok, %Notification{}}

      iex> delete_notification(notification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification(%Notification{} = notification) do
    membership_id = notification.membership_id

    result = Repo.delete(notification)

    case result do
      {:ok, deleted_notification} ->
        # Broadcast updated unread count to user's channel
        Phoenix.PubSub.broadcast(
          TwentyDollarClub.PubSub,
          "notifications:#{membership_id}",
          :unread_count
        )

        {:ok, deleted_notification}

      error ->
        error
    end
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
