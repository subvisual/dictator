defmodule Dictator do
  def config(key, default \\ nil) do
    Application.get_env(:dictator, key, default)
  end
end
