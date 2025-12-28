defmodule TwentyDollarClub.Mpesa.MpesaClient do
  alias TwentyDollarClub.Mpesa.MpesaAuth
  require Logger

  def post(url, body) do
    with {:ok, access_token} <- MpesaAuth.get_access_token(),
         {:ok, response} <- make_request(url, body, access_token) do
      {:ok, response}
    else
      {:error, reason} = error ->
        Logger.error("M-Pesa API request failed: #{inspect(reason)}")
        error
    end
  end

  defp make_request(url, body, access_token) do
    case Req.post(url,
           json: body,
           headers: [
             {"Authorization", "Bearer #{access_token}"},
             {"Content-Type", "application/json"}
           ]
         ) do
      {:ok, %{status: status} = response} when status in 200..299 ->
        {:ok, response}

      {:ok, %{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        {:error, {:request_failed, reason}}
    end
  end
end
