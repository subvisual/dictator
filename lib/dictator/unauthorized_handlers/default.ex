defmodule Dictator.UnauthorizedHandlers.Default do
  @moduledoc """
  Basic unauthorized handler to be called if none is provided.

  When a user is denied access to a resource, an unauthorized handler is
  called.  This is the most basic definition.  Simply returns
  `401 UNAUTHORIZED` with the text "you are not authorized to do that".  No
  content type or any other header is provided.
  """

  @behaviour Plug

  import Plug.Conn

  @impl Plug
  def init(_), do: :ok

  @impl Plug
  def call(conn, _) do
    conn
    |> send_resp(:unauthorized, "you are not authorized to do that")
    |> halt()
  end
end
