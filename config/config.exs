# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :twenty_dollar_club,
  ecto_repos: [TwentyDollarClub.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configure the endpoint
config :twenty_dollar_club, TwentyDollarClubWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: TwentyDollarClubWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: TwentyDollarClub.PubSub,
  live_view: [signing_salt: "zV4fhocQ"]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure Guardian
config :twenty_dollar_club, TwentyDollarClubWeb.Auth.Guardian,
  issuer: "twenty_dollar_club",
  secret_key: "qOD9gdl1Q2bQ4VgIz0PxXJwcs6iXi2Ty1ULTfjvXwieN1myPaCL3yAvVIiT3XaEc"

# Configure Guardian DB
config :guardian, Guardian.DB,
  repo: TwentyDollarClub.Repo,
  schema_name: "guardian_tokens",
  sweep_interval: 60

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
