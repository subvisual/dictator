defmodule Dictator.UnauthorizedHandlers.JsonApi do
  import Phoenix.Controller, only: [json: 2]
  import Plug.Conn, only: [put_status: 2, halt: 1]

  def unauthorized(conn) do
    conn
    |> put_status(:unauthorized)
    |> json(%{})
    |> halt()
  end
end
