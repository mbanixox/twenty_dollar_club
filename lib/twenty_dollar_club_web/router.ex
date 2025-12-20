defmodule TwentyDollarClubWeb.Router do
  use TwentyDollarClubWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TwentyDollarClubWeb do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit]
    resources "/memberships", MembershipController, except: [:new, :edit]
    resources "/beneficiaries", BeneficiaryController, except: [:new, :edit]
    resources "/projects", ProjectController, except: [:new, :edit]
    resources "/contributions", ContributionController, except: [:new, :edit]
    resources "/project_contributions", ProjectContributionController, except: [:new, :edit]
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:twenty_dollar_club, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: TwentyDollarClubWeb.Telemetry
    end
  end
end
