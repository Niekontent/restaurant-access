defmodule RestaurantAccess.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RestaurantAccessWeb.Telemetry,
      RestaurantAccess.Repo,
      {DNSCluster, query: Application.get_env(:restaurant_access, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RestaurantAccess.PubSub},
      # Start a worker by calling: RestaurantAccess.Worker.start_link(arg)
      # {RestaurantAccess.Worker, arg},
      # Start to serve requests, typically the last entry
      RestaurantAccessWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RestaurantAccess.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RestaurantAccessWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
