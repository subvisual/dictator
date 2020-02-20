defmodule Dictator.Policies.Standard do
  defmacro __using__(opts) do
    quote do
      use Dictator.Policy, unquote(opts)

      alias Dictator.Policy

      @impl Policy
      def can?(_, action, _) when action in [:index, :new, :create], do: true

      @impl Policy
      def can?(%{id: user_id}, action, %@module{user_id: user_id})
          when action in [:edit, :update, :delete, :show],
          do: true

      @impl Policy
      def can?(_user, _action, _resource), do: false
    end
  end
end
