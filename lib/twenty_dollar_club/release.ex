defmodule TwentyDollarClub.Release do
  @moduledoc """
  Module for executing DB release tasks when run in production without Mix installed.
  """

  @app :twenty_dollar_club

  def migrate do
    load_app()

    # Use migration URL if available, otherwise fall back to regular DATABASE_URL
    migration_url = System.get_env("DATABASE_URL_DIRECT") || System.get_env("DATABASE_URL")

    # Temporarily override the repo URL for migrations
    original_config = Application.get_env(@app, TwentyDollarClub.Repo)

    Application.put_env(@app, TwentyDollarClub.Repo,
      Keyword.put(original_config, :url, migration_url)
    )

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    # Restore original config
    Application.put_env(@app, TwentyDollarClub.Repo, original_config)

  end

  def rollback(repo, version) do
    load_app()

    # Use direct URL for rollbacks too
    migration_url = System.get_env("DATABASE_URL_DIRECT") || System.get_env("DATABASE_URL")
    original_config = Application.get_env(@app, TwentyDollarClub.Repo)

    Application.put_env(@app, TwentyDollarClub.Repo,
      Keyword.put(original_config, :url, migration_url)
    )

    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))

    # Restore original config
    Application.put_env(@app, TwentyDollarClub.Repo, original_config)
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end

end
