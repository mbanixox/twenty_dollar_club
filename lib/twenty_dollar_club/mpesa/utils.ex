defmodule TwentyDollarClub.Mpesa.Utils do
  @moduledoc """
  Utility functions for M-Pesa API integration.
  """

  @doc """
  Generates a timestamp in the format required by M-Pesa API (YYYYMMDDHHmmss).
  """
  def current_timestamp do
    DateTime.utc_now()
    |> Calendar.strftime("%Y%m%d%H%M%S")
  end

  @doc """
  Generates the password required for M-Pesa STK Push requests.

  The password is a Base64 encoded string of: Shortcode + Passkey + Timestamp
  """
  def password(shortcode, passkey, timestamp) do
    data = "#{shortcode}#{passkey}#{timestamp}"
    Base.encode64(data)
  end
end
