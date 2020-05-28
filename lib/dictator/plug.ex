defmodule Dictator.Plug do
  @behaviour Plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, opts) do
    authorize(conn, opts)
  end

  defp authorize(conn, opts) do
    policy = opts[:policy] || load_policy(conn)
    key = opts[:key] || default_key()
    user = conn.assigns[key]
    action = conn.private[:phoenix_action]

    resource =
      if requires_resource_load?(policy) do
        apply(policy, :load_resource, [conn.params])
      else
        nil
      end

    if apply(policy, :can?, [user, action, %{params: conn.params, resource: resource}]) do
      conn
    else
      unauthorize(conn)
    end
  end

  defp load_policy(conn) do
    conn
    |> extract_policy_module()
    |> ensure_policy_loaded!()
  end

  defp extract_policy_module(conn) do
    conn.private.phoenix_controller
    |> Atom.to_string()
    |> String.split(".")
    |> List.update_at(-1, &String.trim(&1, "Controller"))
    |> List.insert_at(2, "Policies")
    |> Enum.join(".")
    |> String.to_existing_atom()
  end

  defp ensure_policy_loaded!(mod) do
    if Code.ensure_loaded?(mod) do
      mod
    else
      nil
    end
  end

  defp unauthorize(conn) do
    Dictator.config(:unauthorized_handler, Dictator.UnauthorizedHandlers.Default)
    |> apply(:unauthorized, [conn])
  end

  defp default_key do
    Dictator.config(:key, :current_user)
  end

  defp requires_resource_load?(policy) do
    policy.__info__(:attributes)
    |> Keyword.get_values(:behaviour)
    |> List.flatten()
    |> Enum.member?(Dictator.Policies.EctoSchema)
  end
end
