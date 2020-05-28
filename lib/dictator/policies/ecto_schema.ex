if Code.ensure_loaded?(Ecto) do
  defmodule Dictator.Policies.EctoSchema do
    @callback load_resource(map()) :: map() | nil

    @optional_callbacks load_resource: 1

    defmacro __using__(opts) do
      quote do
        alias Dictator.Policies.EctoSchema
        alias Dictator.Policy

        @behaviour EctoSchema
        @behaviour Policy

        @schema Keyword.fetch!(unquote(opts), :for)
        @key Keyword.get(unquote(opts), :key, :id)
        @key_str to_string(@key)
        @repo Keyword.get(unquote(opts), :repo, EctoSchema.default_repo())

        if !@repo do
          raise ArgumentError, "#{unquote(__MODULE__)} has no :repo specified"
        end

        @impl Policy
        def can?(_, _, _), do: false

        @impl EctoSchema
        def load_resource(%{@key_str => value}) do
          @repo.get_by(@schema, [{@key, value}])
        end

        def load_resource(_), do: nil

        defoverridable Dictator.Policies.EctoSchema
        defoverridable can?: 3
      end
    end

    def default_repo do
      Dictator.config(:ecto_repo)
    end
  end
end
