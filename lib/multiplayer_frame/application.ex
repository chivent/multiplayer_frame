defmodule MultiplayerFrame.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MultiplayerFrameWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MultiplayerFrame.PubSub},
      # Start the Endpoint (http/https)
      MultiplayerFrameWeb.Endpoint,
      # Start a worker by calling: MultiplayerFrame.Worker.start_link(arg)
      # {MultiplayerFrame.Worker, arg}
      MultiplayerFrame.RoomSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MultiplayerFrame.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MultiplayerFrameWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
