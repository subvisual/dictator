defmodule Dictator.FetchStrategies.Assigns do
  @behaviour Dictator.FetchStrategy

  @impl true
  def fetch(conn, key) do
    conn.assigns[key]
  end
end
