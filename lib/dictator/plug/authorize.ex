defmodule Dictator.Plug.Authorize do
  import Plug.Conn

  @behaviour Plug

  @default_actions [:index, :show, :new, :create, :edit, :update, :delete]

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, opts) do
    allowed_actions = Keyword.get(opts, :only, @default_actions)
    policy = opts[:policy] || load_policy(conn)

    if conn.private.phoenix_action in allowed_actions do
      authorize(conn, policy)
    else
      conn
    end
  end

  defp authorize(conn, policy) do
    user = conn.assigns.current_user
    action = conn.private.phoenix_action
    resource = apply(policy, :load_resource, [conn.params])

    if apply(policy, :can?, [user, action, resource]) do
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
    conn
    |> send_resp(:unauthorized, "you are not authorized to do that")
    |> halt()
  end
end
