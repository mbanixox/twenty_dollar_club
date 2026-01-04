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

  def handle_errors(conn, %{reason: reason}) do
    conn
    |> json(%{errors: Exception.message(reason)})
    |> halt()
  end

  pipeline :api do
    plug :accepts, ["json"]
    # plug :fetch_session
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

  pipeline :admin_auth do
    plug TwentyDollarClubWeb.Auth.Pipeline
    plug TwentyDollarClubWeb.Auth.SetUser
    plug TwentyDollarClubWeb.Auth.SetMembership
    plug TwentyDollarClubWeb.Auth.SetAdmin
  end

  scope "/api", TwentyDollarClubWeb do
    pipe_through :api

    post "/users/create", UserController, :create
    post "/users/sign_in", UserController, :sign_in

    post "/mpesa/callback", PaymentController, :mpesa_callback
  end

  scope "/api", TwentyDollarClubWeb do
    pipe_through [:api, :user_auth]

    get "/users", UserController, :index
    get "/users/by_id/:id", UserController, :show
    get "/users/refresh_session", UserController, :refresh_session
    post "/users/sign_out", UserController, :sign_out
    patch "/users/update", UserController, :update
    delete "/users/delete", UserController, :delete

    post "/payments/membership", PaymentController, :create_membership_mpesa
  end

  scope "/api", TwentyDollarClubWeb do
    pipe_through [:api, :membership_auth]

    get "/users/with_memberships", UserController, :with_memberships

    get "/memberships", MembershipController, :index
    delete "/memberships/delete", MembershipController, :delete

    get "/membership/beneficiaries", BeneficiaryController, :index
    post "/membership/beneficiaries/create", BeneficiaryController, :create
    get "/membership/beneficiaries/:id", BeneficiaryController, :show
    patch "/membership/beneficiaries/:id", BeneficiaryController, :update
    delete "/membership/beneficiaries/:id", BeneficiaryController, :delete

    get "/membership/projects", ProjectController, :index
    get "/membership/projects/:id", ProjectController, :show

    post "/project/contributions", PaymentController, :create_project_mpesa

    get "/membership/contributions", ContributionController, :index
    post "/membership/contributions", ContributionController, :create
    get "/membership/contributions/:id", ContributionController, :show
    patch "/membership/contributions/:id", ContributionController, :update
    delete "/membership/contributions/:id", ContributionController, :delete

    get "/project/contributions", ProjectContributionController, :index
    get "/project/contributions/:id", ProjectContributionController, :show
    patch "/project/contributions/:id", ProjectContributionController, :update
    delete "/project/contributions/:id", ProjectContributionController, :delete
  end

  scope "/api/admin", TwentyDollarClubWeb do
    pipe_through [:api, :admin_auth]

    patch "/memberships/update", MembershipController, :update

    post "/projects/create", ProjectController, :create
    patch "/projects/:id", ProjectController, :update
    delete "/projects/:id", ProjectController, :delete
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
