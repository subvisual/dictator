defmodule Dictator.FetchStrategy do
  @callback fetch(Plug.Conn.t(), any()) :: map() | nil
end
