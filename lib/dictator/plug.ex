defmodule Dictator.Plug do
  import Plug.Conn

  @behaviour Plug

  @default_actions [:index, :show, :new, :create, :edit, :update, :delete]

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, opts) do
    allowed_actions = Keyword.get(opts, :only, @default_actions)

    if conn.private.phoenix_action in allowed_actions do
      authorize(conn, opts)
    else
      conn
    end
  end

  defp authorize(conn, opts) do
    policy = opts[:policy] || load_policy(conn)
    resource_key = opts[:resource_key] || :current_user
    user = conn.assigns[resource_key]
    action = conn.private.phoenix_action

    target =
      if policy.resourceful?() do
        apply(policy, :load_resource, [conn.params])
      else
        conn.params
      end

    if apply(policy, :can?, [user, action, target]) do
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
    config(:unauthorized_handler, Dictator.UnauthorizedHandlers.Bare)
    |> apply(:unauthorized, [conn])
  end

  defp config(key, default \\ nil) do
    Application.get_env(:dictator, __MODULE__)
    |> Keyword.get(key, default)
  end
end
