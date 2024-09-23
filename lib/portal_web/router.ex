defmodule PortalWeb.Router do
  use PortalWeb, :router

  alias PortalWeb.AuthClients
  alias PortalWeb.AuthCandidate
  alias PortalWeb.ClientSessionController
  alias PortalWeb.ClientLive

  import PortalWeb.ClientAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PortalWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_client
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", PortalWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:portal, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PortalWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # Negative list for authentication.
  # client can't access this if he is authenticated
  scope "/app" do
    pipe_through [:browser, :redirect_if_client_is_authenticated]

    # live session will manage the values of session for the scope
    # define the hooks to be used using the parameters.
    live_session :redirect_if_client_is_authenticated,
      on_mount: [{PortalWeb.ClientAuth, :redirect_if_client_is_authenticated}] do
      live "/register", AuthClients.RegisterLive, :new
      live "/login", AuthClients.LoginLive, :new
      live "/recover", AuthClients.RecoverAccountLive, :new
      live "/recover/:token", AuthClients.RecoverAccountFromTokenLive, :new
    end

    post "/login", ClientSessionController, :create
  end

  scope "/candidate" do
    pipe_through [:browser, :redirect_if_client_is_authenticated]

    # live session will manage the values of session for the scope
    # define the hooks to be used using the parameters.
    # live_session :redirect_if_client_is_authenticated,
    #   on_mount: [{PortalWeb.ClientAuth, :redirect_if_client_is_authenticated}] do
    live "/register", AuthCandidate.RegisterLive, :new
    # live "/login", AuthClients.LoginLive, :new
    # live "/recover", AuthClients.RecoverAccountLive, :new
    # live "/recover/:token", AuthClients.RecoverAccountFromTokenLive, :new
    # end

    # post "/login", ClientSessionController, :create
  end

  # Positive list for authentication.
  # client can access this  ONLY if he is authenticated
  scope "/app" do
    pipe_through [:browser, :require_authenticated_client]

    live_session :require_authenticated_client,
      on_mount: [{PortalWeb.ClientAuth, :ensure_authenticated}] do
      live "/", ClientLive.HomeLive, :new
      live "/help", ClientLive.SupportTicketLive, :new
      live "/jobs", ClientLive.JobsLive, :new
      live "/profile", ClientLive.ProfileLive, :new
      live "/profile/basics/edit", ClientLive.ProfileLive, :edit_profile_basics
      live "/profile/socials/add", ClientLive.ProfileLive, :add_social_profile
      live "/profile/socials/:id/edit", ClientLive.ProfileLive, :edit_social_profile
      live "/profile/locations/add", ClientLive.ProfileLive, :add_location
      live "/profile/locations/:id/edit", ClientLive.ProfileLive, :edit_location
    end
  end

  scope "/" do
    pipe_through [:browser]

    delete "/app/logout", ClientSessionController, :delete

    get "/", PortalWeb.PageController, :home
    get "/about", PortalWeb.PageController, :about
    get "/solutions", PortalWeb.PageController, :solutions
    get "/pricing", PortalWeb.PageController, :pricing
    get "/faq", PortalWeb.PageController, :faq
    get "/terms-and-conditions", PortalWeb.PageController, :terms_and_conditions
    get "/companies", PortalWeb.PageController, :companies
    get "/help-center", PortalWeb.PageController, :help_center
    live "/contact", PortalWeb.Live.ContactLive, :new
    live "/trending", PortalWeb.Live.Jobs.TrendingLive, :new
    get "/company/:id", PortalWeb.PageController, :company_microsite

    # instructions for sending and receiving the email verification token
    live_session :current_client,
      on_mount: [{PortalWeb.ClientAuth, :mount_current_client}] do
      live "/app/confirm/:token", PortalWeb.AuthClients.ClientConfirmationLive, :new
      live "/app/confirm", PortalWeb.AuthClients.ClientConfirmationInstructionsLive, :new
    end
  end
end
