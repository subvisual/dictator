defmodule Dictator.Policies.Bare do
  defmacro __using__(_opts) do
    quote do
      alias Dictator.Policy

      @behaviour Policy

      @impl Policy
      def resourceful?, do: false

      @impl Policy
      def can?(_, _, _), do: false

      defoverridable can?: 3
    end
  end
end
