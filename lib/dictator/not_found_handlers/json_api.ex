defmodule Dictator.NotFoundHandlers.JsonApi do
  @moduledoc """
  JSON API compatible not_found handler.

  Configure your app to use this handler instead of
  `Dictator.NotFoundHandlers.Default` by setting your `config/*.exs` to:

  ```
  config :dictator, not_found_handler: Dictator.NotFoundHandlers.JsonApi
  ```

  This handler sets the `content-type` header to `application/json` and sends
  an empty body with the 404 status as the response.
  """

  @behaviour Plug

  import Plug.Conn

  @impl Plug
  def init(_), do: :ok

  @impl Plug
  def call(conn, _) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(:not_found, "{}")
    |> halt()
  end
end
