defmodule TwentyDollarClub.Mpesa.MpesaAuth do
  @moduledoc """
  Handles authentication for Mpesa API by managing access tokens.

  ## Features

  - Retrieves and caches Mpesa access tokens using Cachex.
  - Automatically refreshes tokens when expired or missing.

  ## Usage

  Call `get_access_token/0` to obtain a valid access token for Mpesa API requests.
  """

  require Logger

  @cache :mpesa_cache
  @cache_key :access_token
  @expiry_buffer 60

  def get_access_token do
    case Cachex.get(@cache, @cache_key) do
      {:ok, token} when not is_nil(token) ->
        {:ok, token}

      _ ->
        refresh_token()
    end
  end

  defp refresh_token do
    config = Application.get_env(:twenty_dollar_club, :mpesa)
    basic_auth = Base.encode64("#{config[:consumer_key]}:#{config[:consumer_secret]}")

    case Req.get(
           "#{config[:base_url]}/oauth/v1/generate?grant_type=client_credentials",
           headers: [{"Authorization", "Basic #{basic_auth}"}]
         ) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        handle_token_response(body)

      {:ok, %{status: status, body: body}} ->
        Logger.error("M-Pesa auth failed with status #{status}: #{inspect(body)}")
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        Logger.error("M-Pesa auth request failed: #{inspect(reason)}")
        {:error, {:request_failed, reason}}
    end
  end

  defp handle_token_response(body) do
    with token when is_binary(token) <- body["access_token"],
         expires_in when is_binary(expires_in) or is_integer(expires_in) <- body["expires_in"] do
      expires_in_int = if is_binary(expires_in), do: String.to_integer(expires_in), else: expires_in
      ttl = max(expires_in_int - @expiry_buffer, 0)

      case Cachex.put(@cache, @cache_key, token, ttl: :timer.seconds(ttl)) do
        {:ok, true} ->
          {:ok, token}

        {:error, reason} ->
          Logger.error("Failed to cache M-Pesa token: #{inspect(reason)}")
          {:error, {:cache_error, reason}}
      end
    else
      _ ->
        Logger.error("Invalid M-Pesa token response format: #{inspect(body)}")
        {:error, {:invalid_response, body}}
    end
  end
end
