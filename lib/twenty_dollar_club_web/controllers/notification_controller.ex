defmodule TwentyDollarClubWeb.NotificationController do
  use TwentyDollarClubWeb, :controller

  alias TwentyDollarClub.Notifications
  alias TwentyDollarClub.Notifications.Notification

  action_fallback TwentyDollarClubWeb.FallbackController

  def index(conn, _params) do
    role = conn.assigns.user.membership.role
    membership_id = conn.assigns.user.membership.id
    notifications = Notifications.list_notifications_for_role(role, membership_id)
    render(conn, :index, notifications: notifications)
  end

  def show(conn, %{"id" => id}) do
    membership_id = conn.assigns.user.membership.id
    notification = Notifications.get_notification_for_member!(id, membership_id)
    render(conn, :show, notification: notification)
  end

  def update(conn, %{"id" => id, "notification" => notification_params}) do
    membership_id = conn.assigns.user.membership.id
    notification = Notifications.get_notification_for_member!(id, membership_id)

    with {:ok, %Notification{} = notification} <-
           Notifications.update_notification_read(notification, notification_params) do
      render(conn, :show, notification: notification)
    end
  end

  def delete(conn, %{"id" => id}) do
    membership_id = conn.assigns.user.membership.id
    notification = Notifications.get_notification_for_member!(id, membership_id)

    with {:ok, %Notification{}} <- Notifications.delete_notification(notification) do
      send_resp(conn, :no_content, "")
    end
  end
end
