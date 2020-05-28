defmodule Dictator.UnauthorizedHandlers.Default do
  import Plug.Conn, only: [send_resp: 3, halt: 1]

  def unauthorized(conn) do
    conn
    |> send_resp(:unauthorized, "you are not authorized to do that")
    |> halt()
  end
end
