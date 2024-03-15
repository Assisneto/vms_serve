defmodule VmsServerWeb.Router do
  use VmsServerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", VmsServerWeb do
    pipe_through :api

    get "/sheet/characteristics/:race_id", SheetController, :get_characteristics_fields

    resources "/sheet", SheetController, only: [:show, :create, :update]
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:vms_server, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: VmsServerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
