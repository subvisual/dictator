defmodule Dictator.NotFoundHandlers.Default do
  @moduledoc """
  Basic not found handler to be called if none is provided.

  When a user is tries to access to a resource and none is found, a not found handler is
  called.  This is the most basic definition.  Simply returns
  `404 NOT FOUND` with the text "Object not found".  No
  content type or any other header is provided.
  """

  @behaviour Plug

  import Plug.Conn

  @impl Plug
  def init(_), do: :ok

  @impl Plug
  def call(conn, _) do
    conn
    |> send_resp(:not_found, "Object not found")
    |> halt()
  end
end
