defmodule Dictator.Policies.Standard do
  defmacro __using__(opts) do
    quote do
      use Dictator.Policy, unquote(opts)

      @foreign_key Keyword.get(unquote(opts), :foreign_key, :user_id)
      @owner_key Keyword.get(unquote(opts), :owner_key, :id)

      alias Dictator.Policy

      @impl Policy
      def can?(_, action, _) when action in [:index, :new, :create], do: true

      @impl Policy
      def can?(%{@owner_key => owner_id}, action, %@module{@foreign_key => owner_id})
          when action in [:edit, :update, :delete, :show],
          do: true

      @impl Policy
      def can?(_user, _action, _resource), do: false
    end
  end
end
