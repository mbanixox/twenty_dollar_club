defmodule TwentyDollarClub.Repo do
  use Ecto.Repo,
    otp_app: :twenty_dollar_club,
    adapter: Ecto.Adapters.Postgres
end
