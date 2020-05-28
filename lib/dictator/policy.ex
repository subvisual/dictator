defmodule Dictator.Policy do
  @callback can?(map() | struct(), atom(), map()) :: bool()

  defmacro __using__(_opts) do
    quote do
      @behaviour Dictator.Policy
    end
  end
end
