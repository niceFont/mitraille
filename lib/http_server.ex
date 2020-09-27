defmodule Mitraille.Application do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Mitraille.Router, options: [port: 4040]}
    ]
    opts = [strategy: :one_for_one, name: Mitraille.Supervisor]

    Logger.info("Starting application...")
    Supervisor.start_link(children, opts)
  end
end
