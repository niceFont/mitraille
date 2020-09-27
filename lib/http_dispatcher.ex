defmodule Mitraille.HttpDispatcher do
  require Logger

  def handle_response(%{body: body, status_code: code}) do
    case code do
      n when n >= 200 and n < 400 -> {:success, code, body}
      n when n >= 400 -> {:fail, code, body}
    end
  end
  def send_request(destination, method, _payload) do
      case Mojito.request(method, destination) do
        {:ok, resp} ->  handle_response(resp)
        {:error, error} -> IO.inspect(error)
      end
  end
end
