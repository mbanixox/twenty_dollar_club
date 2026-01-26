defmodule TwentyDollarClub.NotificationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TwentyDollarClub.Notifications` context.
  """

  @doc """
  Generate a notification.
  """
  def notification_fixture(attrs \\ %{}) do
    {:ok, notification} =
      attrs
      |> Enum.into(%{
        event: "some event",
        message: "some message",
        read: true,
        recipient_type: "some recipient_type",
        severity: "some severity"
      })
      |> TwentyDollarClub.Notifications.create_notification()

    notification
  end
end
