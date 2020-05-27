defmodule Dictator.Policy do
  @callback can?(map() | struct(), atom(), map(), struct() | nil) :: bool()

  @optional_callbacks can?: 4

  defmacro __using__(_opts) do
    quote do
      @behaviour Dictator.Policy

      @impl Dictator.Policy
      def can?(_, _, _, _), do: false

      defoverridable Dictator.Policy
    end
  end
end
