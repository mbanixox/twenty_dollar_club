defmodule TwentyDollarClubWeb.NotificationChannel do
  use TwentyDollarClubWeb, :channel
  alias TwentyDollarClub.Notifications

  @impl true
  def join("notifications:" <> membership_id, _payload, socket) do
    Phoenix.PubSub.subscribe(TwentyDollarClub.PubSub, "notifications:#{membership_id}")

    # Send initial unread count when user joins
    count = Notifications.get_unread_notifications_count(membership_id)
    send(self(), {:after_join, count})

    {:ok, assign(socket, :membership_id, membership_id)}
  end

  # Send initial count after join
  @impl true
  def handle_info({:after_join, count}, socket) do
    push(socket, "unread_count", %{count: count})
    {:noreply, socket}
  end

  # Handle broadcast from PubSub when count needs to update
  @impl true
  def handle_info(:unread_count, socket) do
    membership_id = socket.assigns.membership_id
    count = Notifications.get_unread_notifications_count(membership_id)
    push(socket, "unread_count", %{count: count})
    {:noreply, socket}
  end

  # Broadcast new notification to user
  @impl true
  def handle_info({:new_notification, notification}, socket) do
    push(socket, "new_notification", %{
      id: notification.id,
      event: notification.event,
      message: notification.message,
      read: notification.read,
      severity: notification.severity,
      resource_type: notification.resource_type,
      recipient_type: notification.recipient_type,
      inserted_at: notification.inserted_at
    })

    # Also send updated unread count
    membership_id = socket.assigns.membership_id
    count = Notifications.get_unread_notifications_count(membership_id)
    push(socket, "unread_count", %{count: count})

    {:noreply, socket}
  end

  # Handle client request for unread count (manual refresh)
  @impl true
  def handle_in("get_unread_count", _payload, socket) do
    membership_id = socket.assigns.membership_id
    count = Notifications.get_unread_notifications_count(membership_id)
    push(socket, "unread_count", %{count: count})
    {:noreply, socket}
  end
end
