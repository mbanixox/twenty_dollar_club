defmodule TwentyDollarClub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Cachex, name: :mpesa_cache},
      TwentyDollarClubWeb.Telemetry,
      TwentyDollarClub.Repo,
      {DNSCluster,
       query: Application.get_env(:twenty_dollar_club, :dns_cluster_query) || :ignore},
      {Oban, Application.fetch_env!(:twenty_dollar_club, Oban)},
      {Phoenix.PubSub, name: TwentyDollarClub.PubSub},
      # Start a worker by calling: TwentyDollarClub.Worker.start_link(arg)
      # {TwentyDollarClub.Worker, arg},
      # Start to serve requests, typically the last entry
      Guardian.DB.Sweeper,
      TwentyDollarClubWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TwentyDollarClub.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TwentyDollarClubWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
