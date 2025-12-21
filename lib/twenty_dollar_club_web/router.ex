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

  pipeline :auth do
    plug TwentyDollarClubWeb.Auth.Pipeline
    plug TwentyDollarClubWeb.Auth.SetUser
  end


  scope "/api", TwentyDollarClubWeb do
    pipe_through :api

    post "/users/create", UserController, :create
    post "/users/sign_in", UserController, :sign_in

    # resources "/users", UserController, except: [:new, :edit]
    # resources "/memberships", MembershipController, except: [:new, :edit]
    # resources "/beneficiaries", BeneficiaryController, except: [:new, :edit]
    # resources "/projects", ProjectController, except: [:new, :edit]
    # resources "/contributions", ContributionController, except: [:new, :edit]
    # resources "/project_contributions", ProjectContributionController, except: [:new, :edit]
  end

  scope "/api", TwentyDollarClubWeb do
    pipe_through [:api, :auth]

    get "/users/by_id/:id", UserController, :show
    post "/users/sign_out", UserController, :sign_out
    post "/users/update", UserController, :update
    delete "/users/delete/:id", UserController, :delete
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
