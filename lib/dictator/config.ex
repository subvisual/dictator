defmodule Dictator.Config do
  @moduledoc """
  Helpers to get the dictator configs. Intended for internal use only.
  """
  def get(key, default \\ nil) do
    Application.get_env(:dictator, key, default)
  end
end
