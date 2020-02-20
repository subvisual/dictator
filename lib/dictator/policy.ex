defmodule Dictator.Policy do
  @callback can?(%{}, atom(), map()) :: bool()
  @callback load_resource(map()) :: map() | nil

  @optional_callbacks can?: 3, load_resource: 1

  def infer_repo_for(mod) do
    case get_repo_from_namespace(mod) do
      {:ok, repo} -> repo
      _error -> get_repo_from_application(mod)
    end
  end

  defp get_repo_from_namespace(mod) do
    with [namespace | _] <- Module.split(mod),
         repo <- Module.concat(namespace, "Repo"),
         true <- Code.ensure_loaded?(repo) do
      {:ok, repo}
    else
      _error ->
        {:error, :no_repo_found}
    end
  end

  defp get_repo_from_application(mod) do
    with {:ok, application} <- :application.get_application(mod),
         [repo] <- Application.get_env(application, :ecto_repos) do
      repo
    else
      _error ->
        raise ArgumentError,
              "couldn't infer repo, please provide one via the :repo option"
    end
  end

  defmacro __using__(opts) do
    quote do
      alias Auth.Policy

      @behaviour Policy
      @module Keyword.fetch!(unquote(opts), :for)
      @key Keyword.get(unquote(opts), :key, :id)
      @repo Keyword.get(unquote(opts), :repo, Policy.infer_repo_for(@module))

      def can?(_, _, _), do: true

      def load_resource(nil), do: nil

      def load_resource(params) do
        with false <- Enum.empty?(params),
             value when not is_nil(value) <-
               get_with_indifferent_access(params, @key) do
          @repo.get_by(@module, [{@key, value}])
        else
          _ -> nil
        end
      end

      defoverridable can?: 3, load_resource: 1

      defp get_with_indifferent_access(map, key) when is_atom(key) do
        case Map.get(map, key) do
          nil -> Map.get(map, to_string(key))
          value -> value
        end
      end

      defp get_with_indifferent_access(map, key) when is_binary(key) do
        case Map.get(map, key) do
          nil -> Map.get(map, String.to_atom(key))
          value -> value
        end
      end
    end
  end
end
