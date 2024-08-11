defmodule RFDataViewer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RFDataViewerWeb.Telemetry,
      RFDataViewer.Repo,
      {DNSCluster, query: Application.get_env(:rf_data_viewer, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RFDataViewer.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: RFDataViewer.Finch},
      # Start a worker by calling: RFDataViewer.Worker.start_link(arg)
      # {RFDataViewer.Worker, arg},
      # Start to serve requests, typically the last entry
      RFDataViewerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RFDataViewer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RFDataViewerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
