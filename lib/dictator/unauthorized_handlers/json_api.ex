defmodule Dictator.UnauthorizedHandlers.JsonApi do
  import Plug.Conn

  def unauthorized(conn) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(:unauthorized, "{}")
    |> halt()
  end
end
