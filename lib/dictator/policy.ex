defmodule Dictator.Policy do
  @callback can?(map() | struct(), atom(), map()) :: bool()

  @optional_callbacks can?: 3

  defmacro __using__(_opts) do
    quote do
      @behaviour Dictator.Policy

      @impl Dictator.Policy
      def can?(_, _, _), do: false

      defoverridable Dictator.Policy
    end
  end
end
