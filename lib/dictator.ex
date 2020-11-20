defmodule Dictator do
  @moduledoc """
  Plug that checks if your users are authorised to access the resource.

  You can use it at the router or controller level:

  ```
  # lib/my_app_web/controllers/post_controller.ex
  defmodule MyApp.PostController do
    plug Dictator

    def show(conn, params) do
      # ...
    end
  end

  # lib/my_app_web/router.ex
  defmodule MyAppWeb.Router do
    pipeline :authorised do
      plug Dictator
    end
  end
  ```

  Requires Phoenix (or at least `conn.private[:phoenix_action]` to be set).
  To load resources from the database, requires Ecto. See `Dictator.Policies.EctoSchema`.

  Dictator assumes your policies are in `lib/my_app_web/policies/` and follow
  the `MyAppWeb.Policies.Name` naming convention. As an example, for posts,
  `MyAppWeb.Policies.Post` would be defined in
  `lib/my_app_web/policies/post.ex`.

  It is also assumed the current user is loaded and available on
  `conn.assigns`. By default, it is assumed to be under
  `conn.assigns[:current_user]`, although this option can be overriden.

  ## Plug Options

  Options that you can pass to the module, when plugging it (e.g. `plug
  Dictator, only: [:create, :update]`). None of the following options are
  required.

  * `only`: limits the actions to perform authorisation on to the provided list.
  * `except`: limits the actions to perform authorisation on to exclude the provided list.
  * `policy`: policy to apply. See above to understand how policies are inferred.
  * `key`: key under which the current user is placed in `conn.assigns` or the
  session. Defaults to `:current_user`.
  * `fetch_strategy`: Strategy to be used to get the current user. Can be
  either `Dictator.FetchStrategies.Assigns` to fetch it from `conn.assigns` or
  `Dictator.FetchStrategies.Session` to fetch it from the session. You can also
  implement your own strategy and pass it in this option or set it in the
  config.  Defaults to `Dictator.FetchStrategies.Assigns`.

  ## Configuration options

  Options that you can place in your `config/*.exs` files.

  * `key`: Same as the `:key` parameter in the plug option section. The plug option takes precedence, meaning you can place it in a config and then override it in specific controllers or pipelines.
  * `unauthorized_handler`: Handler to be called when the user is not authorised to access the resource. Defaults to `Dictator.UnauthorizedHandlers.Default`.
  * `not_found_handler`: Handler to be called when the object being accessed in the call does not exist. Defaults to `Dictator.UnauthorizedHandlers.Default`.
  """

  @behaviour Plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, opts) do
    if should_authorize?(conn, opts) do
      authorize(conn, opts)
    else
      conn
    end
  end

  defp should_authorize?(conn, opts) do
    action = conn.private[:phoenix_action]

    cond do
      opts[:only] -> action in opts[:only]
      opts[:except] -> action not in opts[:except]
      true -> true
    end
  end

  defp authorize(conn, opts) do
    policy = opts[:policy] || load_policy(conn)
    key = opts[:key] || default_key()
    fetch_strategy = opts[:fetch_strategy] || default_fetch_strategy()
    user = apply(fetch_strategy, :fetch, [conn, key])
    action = conn.private[:phoenix_action]

    resource =
      if requires_resource_load?(policy) do
        apply(policy, :load_resource, [conn.params])
      else
        nil
      end

    params = %{params: conn.params, resource: resource, opts: opts}

    case apply(policy, :can?, [user, action, params]) do
      true ->
        conn

      false ->
        unauthorized_handler = unauthorized_handler()
        opts = unauthorized_handler.init(opts)
        unauthorized_handler.call(conn, opts)

      nil ->
        not_found_handler = not_found_handler()
        opts = not_found_handler.init(opts)
        not_found_handler.call(conn, opts)
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

  defp default_key do
    Dictator.Config.get(:key, :current_user)
  end

  defp default_fetch_strategy do
    Dictator.Config.get(:fetch_strategy, Dictator.FetchStrategies.Assigns)
  end

  defp unauthorized_handler do
    Dictator.Config.get(:unauthorized_handler, Dictator.UnauthorizedHandlers.Default)
  end

  defp not_found_handler do
    Dictator.Config.get(:not_found_handler, Dictator.NotFoundHandlers.Default)
  end

  defp requires_resource_load?(policy) do
    policy.__info__(:attributes)
    |> Keyword.get_values(:behaviour)
    |> List.flatten()
    |> Enum.member?(Dictator.Policies.EctoSchema)
  end
end
