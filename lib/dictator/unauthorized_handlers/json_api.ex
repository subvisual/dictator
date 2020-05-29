defmodule Dictator.UnauthorizedHandlers.JsonApi do
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
