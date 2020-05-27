if Code.ensure_loaded?(Ecto) do
  defmodule Dictator.Policies.BelongsTo do
    defmacro __using__(opts) do
      quote do
        use Dictator.Policies.EctoSchema, unquote(opts)

        @foreign_key Keyword.get(unquote(opts), :foreign_key, :user_id)
        @owner_key Keyword.get(unquote(opts), :owner_key, :id)

        alias Dictator.Policy

        @impl Policy
        def can?(_, action, _, _) when action in [:index, :show, :new, :create], do: true

        @impl Policy
        def can?(%{@owner_key => owner_id}, action, _, %@schema{@foreign_key => owner_id})
            when action in [:edit, :update, :delete],
            do: true

        @impl Policy
        def can?(_user, _action, _params, _resource), do: false

        defoverridable can: 4
      end
    end
  end
end
