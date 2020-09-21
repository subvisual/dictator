defmodule Dictator.FetchStrategies.Session do
  @behaviour Dictator.FetchStrategy

  @impl true
  def fetch(conn, key) do
    Plug.Conn.get_session(conn, key)
  end
end
