defmodule TwentyDollarClubWeb.PaymentController do
  @moduledoc """
  Handles payment-related actions.
  """

  use TwentyDollarClubWeb, :controller

  alias TwentyDollarClub.Mpesa.StkPush
  alias TwentyDollarClubWeb.FallbackController

  action_fallback FallbackController

  @doc """
  Initiates an M-Pesa STK Push request.

  Expects `phone` and `amount` in the request body.
  """
  def create_membership(conn, %{"phone" => phone, "amount" => amount}) do
    case StkPush.push(phone, amount, "Create membership") do
      {:ok, response} ->
        conn
        |> put_status(:ok)
        |> json(%{status: "success", data: response.body})

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{status: "error", reason: reason})
    end
  end
end
