defmodule TwentyDollarClubWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :twenty_dollar_club,
    module: TwentyDollarClubWeb.Auth.Guardian,
    error_handler: TwentyDollarClubWeb.Auth.GuardianErrorHandler

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
