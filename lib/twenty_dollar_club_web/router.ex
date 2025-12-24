defmodule TwentyDollarClubWeb.Router do
  use TwentyDollarClubWeb, :router
  use Plug.ErrorHandler

  def handle_errors(conn, %{reason: %Phoenix.Router.NoRouteError{message: message}}) do
    conn
    |> json(%{errors: message})
    |> halt()
  end

  def handle_errors(conn, %{reason: %{message: message}}) do
    conn
    |> json(%{errors: message})
    |> halt()
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :user_auth do
    plug TwentyDollarClubWeb.Auth.Pipeline
    plug TwentyDollarClubWeb.Auth.SetUser
  end

  pipeline :membership_auth do
    plug TwentyDollarClubWeb.Auth.Pipeline
    plug TwentyDollarClubWeb.Auth.SetUser
    plug TwentyDollarClubWeb.Auth.SetMembership
  end

  scope "/api", TwentyDollarClubWeb do
    pipe_through :api

    post "/users/create", UserController, :create
    post "/users/sign_in", UserController, :sign_in
  end

  scope "/api", TwentyDollarClubWeb do
    pipe_through [:api, :user_auth]

    get "/users", UserController, :index
    get "/users/by_id/:id", UserController, :show
    get "/users/refresh_session", UserController, :refresh_session
    post "/users/sign_out", UserController, :sign_out
    patch "/users/update", UserController, :update
    delete "/users/delete", UserController, :delete
  end

  scope "/api", TwentyDollarClubWeb do
    pipe_through [:api, :membership_auth]

    get "/memberships", MembershipController, :index
    patch "/memberships/update", MembershipController, :update
    delete "/memberships/delete", MembershipController, :delete

    get "/membership/beneficiaries", BeneficiaryController, :index
    post "/membership/beneficiaries", BeneficiaryController, :create
    get "/membership/beneficiaries/:id", BeneficiaryController, :show
    patch "/membership/beneficiaries/:id", BeneficiaryController, :update
    delete "/membership/beneficiaries/:id", BeneficiaryController, :delete

    get "/membership/projects", ProjectController, :index
    post "/membership/projects", ProjectController, :create
    get "/membership/projects/:id", ProjectController, :show
    patch "/membership/projects/:id", ProjectController, :update
    delete "/membership/projects/:id", ProjectController, :delete

    get "/membership/contributions", ContributionController, :index
    post "/membership/contributions", ContributionController, :create
    get "/membership/contributions/:id", ContributionController, :show
    patch "/membership/contributions/:id", ContributionController, :update
    delete "/membership/contributions/:id", ContributionController, :delete

    get "/project/contributions", ProjectContributionController, :index
    post "/project/contributions", ProjectContributionController, :create
    get "/project/contributions/:id", ProjectContributionController, :show
    patch "/project/contributions/:id", ProjectContributionController, :update
    delete "/project/contributions/:id", ProjectContributionController, :delete
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
