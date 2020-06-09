defmodule Dictator.UnauthorizedHandlers.JsonApi do
  @moduledoc """
  JSON API compatible unauthorized handler.

  Configure your app to use this handler instead of
  `Dictator.UnauthorizedHandlers.Default` by setting your `config/*.exs` to:

  ```
  config :dictator, unauthorized_handler: Dictator.UnauthorizedHandlers.JsonApi
  ```

  This handler sets the `content-type` header to `application/json` and sends
  an empty body with the 401 status as the response.
  """

  @behaviour Plug

  import Plug.Conn

  @impl Plug
  def init(_), do: :ok

  @impl Plug
  def call(conn, _) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(:unauthorized, "{}")
    |> halt()
  end
end
