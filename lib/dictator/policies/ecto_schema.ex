if Code.ensure_loaded?(Ecto) do
  defmodule Dictator.Policies.EctoSchema do
    @moduledoc """
    Policy definition with resource loading. Requires Ecto.

    By default, Dictator does not fetch the resource being accessed. As an
    example, if the user is trying to `GET /posts/1`, no post is actually
    loaded, unless your policy `use`s `Dictator.Policies.EctoSchema`.

    By doing so, the third parameter in the `can?/3` function includes the
    resource being accessed under the `resource` key.

    When `use`-ing `Dictator.Policies.EctoSchema`, the following options are
    available:

    * `for` (required): schema to be loaded, e.g `MyApp.Content.Post`
    * `repo`: `Ecto.Repo` to be used. Can also be provided through a
    configuration option.
    * `key`: resource identifier. Defaults to `:id`.
    If you want your resource to be fetched through a different key (e.g
    `uuid`), use this option. Beware that, unless `c:load_resource/1` is
    overriden, there needs to be a match between the `key` value and the
    parameter used. If you want to fetch your resource through a `uuid`
    attribute, there needs to be a corresponding `"uuid"` parameter. See
    [Callback Overrides](#module-callback-overrides) for alternatives to
    loading resources from the database.

    ## Configuration Options

    Options that you can place in your `config/*.exs` files.

    * `repo`: Same as the `:repo` parameter in above section. The `use`
    option takes precedence, meaning you can place a global repo in your
    config and then override it in specific policies.

    ## Callback Overrides

    By default two callbacks are defined: `c:can?/3` and `c:load_resource/1`.

    The former defaults to `false`, meaning **you should always override it
    to correctly define your policy**.

    The latter attempts to load the resource with a given `:key` (see the
    allowed parameters), assuming an equivalent string `"key"` is available
    in the HTTP parameters.

    This means that if you have a `Post` schema which is identified by an
    `id`, then you don't need to override, provided all routes refer to the
    post using an `"id"` parameter:

    ```
    # lib/my_app_web/router.ex
    resources "/posts", PostController

    # lib/my_app_web/policies/post.ex
    defmodule MyAppWeb.Policies.Post do
      use Dictator.Policies.EctoSchema, for: MyApp.Post

      # override can?/3 here
      # ...
    end
    ```

    If, instead, you use `uuid` to identify posts, you should do the following:

    ```
    # lib/my_app_web/router.ex
    resources "/posts", PostController, param: "uuid"

    # lib/my_app_web/policies/post.ex
    defmodule MyAppWeb.Policies.Post do
      use Dictator.Policies.EctoSchema, for: MyApp.Post, key: :uuid

      # override can?/3 here
      # ...
    end
    ```

    If, however, you use a mixture of both, you should override
    `c:load_resource/3`. This example assumes the primary key for your `Post`
    is `uuid` but the routes use `id`.

    ```
    # lib/my_app_web/router.ex
    resources "/posts", PostController

    # lib/my_app_web/policies/post.ex
    defmodule MyAppWeb.Policies.Post do
      use Dictator.Policies.EctoSchema, for: MyApp.Post

      def load_resource(params) do
        MyApp.Repo.get_by(MyApp.Post, uuid: params["id"])
      end

      # override can?/3 here
      # ...
    end
    ```
    """

    @doc """
    Overridable callback to load from the database the resource being accessed.

    Receives the HTTP parameters. Should return the resource or `nil` if none
    is found.
    """
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

    @doc """
    Fetches the `Ecto.Repo` from the config. Intended for internal use.
    """
    def default_repo do
      Dictator.Config.get(:ecto_repo)
    end
  end
end
