defmodule MillasLanpassWeb.Router do
  use MillasLanpassWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MillasLanpassWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MillasLanpassWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/login", PageController, :login
    get "/dashboard", PageController, :dashboard

    # Rutas live
    live "/usuarios/:id", UsuarioLive
  end

  scope "/api", MillasLanpassWeb do
    pipe_through :api

    # Usuarios
    resources "/usuarios", UsuarioController, except: [:new, :edit] do
      get "/estado", UsuarioController, :estado, on: :member
      get "/transacciones", TransaccionController, :historial, on: :member
    end

    # Transacciones
    resources "/transacciones", TransaccionController, except: [:new, :edit]

    # Rutas personalizadas EXPLÍCITAS (sin nesting)
    post "/transacciones/acumular", TransaccionController, :acumular
    post "/transacciones/canjear", TransaccionController, :canjear
  end
  # Other scopes may use custom stacks.
  # scope "/api", MillasLanpassWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:millas_lanpass, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MillasLanpassWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
