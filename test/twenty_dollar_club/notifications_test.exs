defmodule TwentyDollarClub.NotificationsTest do
  use TwentyDollarClub.DataCase

  alias TwentyDollarClub.Notifications

  describe "notifications" do
    alias TwentyDollarClub.Notifications.Notification

    import TwentyDollarClub.NotificationsFixtures

    @invalid_attrs %{message: nil, read: nil, severity: nil, event: nil, recipient_type: nil}

    test "list_notifications/0 returns all notifications" do
      notification = notification_fixture()
      assert Notifications.list_notifications() == [notification]
    end

    test "get_notification!/1 returns the notification with given id" do
      notification = notification_fixture()
      assert Notifications.get_notification!(notification.id) == notification
    end

    test "create_notification/1 with valid data creates a notification" do
      valid_attrs = %{message: "some message", read: true, severity: "some severity", event: "some event", recipient_type: "some recipient_type"}

      assert {:ok, %Notification{} = notification} = Notifications.create_notification(valid_attrs)
      assert notification.message == "some message"
      assert notification.read == true
      assert notification.severity == "some severity"
      assert notification.event == "some event"
      assert notification.recipient_type == "some recipient_type"
    end

    test "create_notification/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_notification(@invalid_attrs)
    end

    test "update_notification/2 with valid data updates the notification" do
      notification = notification_fixture()
      update_attrs = %{message: "some updated message", read: false, severity: "some updated severity", event: "some updated event", recipient_type: "some updated recipient_type"}

      assert {:ok, %Notification{} = notification} = Notifications.update_notification(notification, update_attrs)
      assert notification.message == "some updated message"
      assert notification.read == false
      assert notification.severity == "some updated severity"
      assert notification.event == "some updated event"
      assert notification.recipient_type == "some updated recipient_type"
    end

    test "update_notification/2 with invalid data returns error changeset" do
      notification = notification_fixture()
      assert {:error, %Ecto.Changeset{}} = Notifications.update_notification(notification, @invalid_attrs)
      assert notification == Notifications.get_notification!(notification.id)
    end

    test "delete_notification/1 deletes the notification" do
      notification = notification_fixture()
      assert {:ok, %Notification{}} = Notifications.delete_notification(notification)
      assert_raise Ecto.NoResultsError, fn -> Notifications.get_notification!(notification.id) end
    end

    test "change_notification/1 returns a notification changeset" do
      notification = notification_fixture()
      assert %Ecto.Changeset{} = Notifications.change_notification(notification)
    end
  end
end
