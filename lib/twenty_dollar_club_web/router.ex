defmodule TwentyDollarClubWeb.Router do
  use TwentyDollarClubWeb, :router
  import Oban.Web.Router
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

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
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

  pipeline :super_admin_auth do
    plug TwentyDollarClubWeb.Auth.Pipeline
    plug TwentyDollarClubWeb.Auth.SetUser
    plug TwentyDollarClubWeb.Auth.SetMembership
    plug TwentyDollarClubWeb.Auth.SetSuperAdmin
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
    get "/users/membership_status/:id", UserController, :check_membership_status

    post "/payments/membership", PaymentController, :create_membership_mpesa
  end

  scope "/api", TwentyDollarClubWeb do
    pipe_through [:api, :membership_auth]

    get "/users/with_memberships", UserController, :with_memberships
    get "/users/with_memberships/:id", UserController, :show_with_membership

    get "/memberships", MembershipController, :index
    get "/memberships/:id", MembershipController, :show
    delete "/memberships/delete", MembershipController, :delete

    get "/membership/beneficiaries", BeneficiaryController, :index
    post "/membership/beneficiaries/create", BeneficiaryController, :create
    get "/membership/beneficiaries/:id", BeneficiaryController, :show
    patch "/membership/beneficiaries/:id", BeneficiaryController, :update
    delete "/membership/beneficiaries/:id", BeneficiaryController, :delete

    get "/membership/projects", ProjectController, :index
    get "/membership/projects/:id", ProjectController, :show

    post "/project/contributions", PaymentController, :project_payment_mpesa

    get "/contributions", ContributionController, :index
    get "/contributions/:id", ContributionController, :show
    get "/contributions/member/:member_id", ContributionController, :member_contributions
    get "/contributions/project/:project_id", ContributionController, :project_contributions

    post "/reports/generate", ReportController, :generate
    get "/reports/download/:filename", ReportController, :download

    get "/notifications", NotificationController, :index
    patch "/notifications/:id", NotificationController, :update
    delete "/notifications/:id", NotificationController, :delete
  end

  scope "/api/admin", TwentyDollarClubWeb do
    pipe_through [:api, :admin_auth]

    get "/users/pending", UserController, :list_pending
    patch "/users/approve/:id", UserController, :approve_user_membership
    patch "/users/reject/:id", UserController, :reject_user_membership

    patch "/memberships/update/:id", MembershipController, :update

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

    scope "/" do
      pipe_through [:browser, :super_admin_auth]

      oban_dashboard("/oban")
    end
  end
end
