if Code.ensure_loaded?(Ecto) do
  defmodule Dictator.Policies.BelongsTo do
    @moduledoc """
    Policy definition commonly used in typical `belongs_to` associations.

    This policy assumes the users can read (`:show`, `:index`, `:new`,
    `:create`) any information but only write (`:edit`, `:update`, `:delete`)
    their own.

    As an example, in a typical Twitter-like application, a user `has_many`
    posts and a post `belongs_to` a user. You can define a policy to let users
    manage their own posts but read all others by doing the following:

    ```
    defmodule MyAppWeb.Policies.Post do
      alias MyApp.{Post, User}

      use Dictator.Policies.EctoSchema, for: Post

      def can?(_, action, _) when action in [:index, :show, :new, :create], do: true

      def can?(%User{id: id}, action, %{resource: %Post{user_id: id}})
          when action in [:edit, :update, :delete],
          do: true

      def can?(_, _, _), do: false
    end
    ```

    This scenario is so common, it is abstracted completely through this module
    and you can simply `use Dictator.Policies.BelongsTo, for: Post` to make
    use of it. The following example is equivalent to the previous one:

    ```
    defmodule MyAppWeb.Policies.Post do
      use Dictator.Policies.BelongsTo, for: MyApp.Post
    end
    ```

    ## Allowed Options

    All options available in `Dictator.Policies.EctoSchema` plus the following:

    * `foreign_key`: foreign key of the current user in the resource being
    accessed. If a Post belongs to a User, this option would typically be
    `:user_id`. Defaults to `:user_id`.
    * `owner_key`: primary key of the current user. Defaults to `:id`

    ## Examples

    Assuming a typical `User` schema, with an `:id` primary key, and a typical
    `Post` schema, with a `belongs_to` association to a `User`:

    ```
    # lib/my_app_web/policies/post.ex
    defmodule MyAppWeb.Policies.Post do
      use Dictator.Policies.BelongsTo, for: MyApp.Post
    end
    ```

    If, however, the user has a `uuid` primary key and the post has an
    `admin_id` key instead of the typical `uer_id`, you should do the
    following:

    ```
    # lib/my_app_web/policies/post.ex
    defmodule MyAppWeb.Policies.Post do
      use Dictator.Policies.BelongsTo, for: MyApp.Post, owner_key: :uuid,
        foreign_key: :admin_id
    end
    ```
    """

    defmacro __using__(opts) do
      quote do
        use Dictator.Policies.EctoSchema, unquote(opts)

        @foreign_key Keyword.get(unquote(opts), :foreign_key, :user_id)
        @owner_key Keyword.get(unquote(opts), :owner_key, :id)

        alias Dictator.Policy

        @impl Policy
        def can?(_, action, _) when action in [:index, :show, :new, :create], do: true

        @impl Policy
        def can?(%{@owner_key => owner_id}, action, %{
              resource: %@schema{@foreign_key => owner_id}
            })
            when action in [:edit, :update, :delete],
            do: true

        @impl Policy
        def can?(_user, _action, _params), do: false
      end
    end
  end
end
