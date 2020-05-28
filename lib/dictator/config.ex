defmodule Dictator.Config do
  def get(key, default \\ nil) do
    Application.get_env(:dictator, key, default)
  end
end
