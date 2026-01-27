defmodule TwentyDollarClubWeb.NotificationJSON do
  alias TwentyDollarClub.Notifications.Notification

  @doc """
  Renders a list of notifications.
  """
  def index(%{notifications: notifications}) do
    %{data: for(notification <- notifications, do: data(notification))}
  end

  @doc """
  Renders a single notification.
  """
  def show(%{notification: notification}) do
    %{data: data(notification)}
  end

  defp data(%Notification{} = notification) do
    %{
      id: notification.id,
      event: notification.event,
      message: notification.message,
      read: notification.read,
      severity: notification.severity,
      recipient_type: notification.recipient_type,
      resource_type: notification.resource_type,
      inserted_at: notification.inserted_at,
    }
  end
end
