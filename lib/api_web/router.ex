defmodule ReviewAppWeb.Router do
  use ReviewAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ReviewAppWeb.LayoutView, :root}
    # plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug Ueberauth
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug ReviewAppWeb.Plugs.Api
  end

  pipeline :auth do
    plug ReviewAppWeb.Plugs.Authenticate
  end

  scope "/auth", ReviewAppWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback

    post "/logout", AuthController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", ReviewAppWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    live "/page", ReviewAppWeb.PageLive, :index

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ReviewAppWeb.Telemetry
    end
  end

  scope "/api", ReviewAppWeb do
    pipe_through [:browser, :api, :auth]

    get "/me", AuthController, :me
  end
end
