defmodule TwentyDollarClubWeb.UserSocket do
  use Phoenix.Socket

  channel "payment:*", TwentyDollarClubWeb.PaymentChannel
  channel "report:*", TwentyDollarClubWeb.ReportChannel
  channel "notifications:*", TwentyDollarClubWeb.NotificationChannel

  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
