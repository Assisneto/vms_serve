defmodule VmsServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      VmsServerWeb.Telemetry,
      VmsServer.Repo,
      {DNSCluster, query: Application.get_env(:vms_server, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: VmsServer.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: VmsServer.Finch},
      # Start a worker by calling: VmsServer.Worker.start_link(arg)
      # {VmsServer.Worker, arg},
      # Start to serve requests, typically the last entry
      VmsServerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VmsServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VmsServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
