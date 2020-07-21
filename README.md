# Dictator

Dictator is a plug-based authorization mechanism.

Dictate what your users can access in fewer than 10 lines of code:

```elixir
# config/config.exs
config :dictator, repo: Client.Repo

# lib/client_web/controllers/thing_controller.ex
defmodule ClientWeb.ThingController do
  use ClientWeb, :controller

  plug Dictator

  # ...
end

# lib/client_web/policies/thing.ex
defmodule ClientWeb.Policies.Thing do
  alias Client.Context.Thing

  use Dictator.Policies.BelongsTo, for: Thing
end
```

And that's it! Just like that your users can edit, see and delete their own
`Thing`s but not `Thing`s belonging to other users.

---

- [Installation](#installation)
- [Usage](#usage)
  - [Custom policies](#custom-policies)
    - [`Dictator.Policies.EctoSchema`](#dictator.policies.ectoschema)
    - [`Dictator.Policies.BelongsTo`](#dictator.policies.belongsto)
  - [Plug Options](#plug-options)
    - [Limitting the actions to be authorized](#limitting-the-actions-to-be-authorized)
    - [Overriding the policy to be used](#overriding-the-policy-to-be-used)
    - [Overriding the current user key](#overriding-the-current-user-key)
  - [Configuration Options](#configuration-options)
    - [Setting a default repo](#setting-a-default-repo)
    - [Setting a default user key](#setting-a-default-current-user-key)
    - [Setting the unauthorized handler](#setting-the-unauthorized-handler)
- [Contributing](#contributing)
- [Setup](#setup)
- [Other Projects](#other-projects)
- [About](#about)

## Installation

First, you need to add `:dictator` to your list of dependencies on your `mix.exs`:

```elixir
def deps do
  [{:dictator, "~> 1.0"}]
end
```

## Usage

To authorize your users, just add in your controller:

```elixir
defmodule ClientWeb.ThingController do
  use ClientWeb, :controller

  plug Dictator

  # ...
end
```

Alternatively, you can also do it at the router level:

```elixir
defmodule ClientWeb.Router do
  pipeline :authorised do
    plug Dictator
  end
end
```

That plug will automatically look for a `ClientWeb.Policies.Thing` module, which
should `use Dictator.Policy`. It is a simple module that should implement
`can?/3`. It receives the current user, the action it is trying to perform and a
map containing the `conn.params`, the resource being acccessed and any options
passed when `plug`-ing Dictator.

In `lib/client_web/policies/thing.ex`:

```elixir
defmodule ClientWeb.Policies.Thing do
  alias Client.Context.Thing

  use Dictator.Policies.EctoSchema, for: Thing

  # User can edit, update, delete and show their own things
  def can?(%User{id: user_id}, action, %{resource: %Thing{user_id: user_id}})
    when action in [:edit, :update, :delete, :show], do: true

  # Any user can index, new and create things
  def can?(_, action, _) when action in [:index, :new, :create], do: true

  # Users can't do anything else (users editing, updating, deleting and showing)
  # on things they don't own
  def can?(_, _, _), do: false
end
```

This exact scenario is, in fact, so common that already comes bundled as
`Dictator.Policies.BelongsTo`. This is equivalent to the previous definition:

```elixir
defmodule ClientWeb.Policies.Thing do
  alias Client.Context.Thing

  use Dictator.Policies.BelongsTo, for: Thing
end
```

**IMPORTANT: Dictator assumes you have your current user in your
`conn.assigns`. See our [demo app](https://github.com/subvisual/dictator_demo)
for an example on integrating with guardian.**

---

### Custom Policies

Dictator comes bundled with three different types of policies:

- **`Dictator.Policies.EctoSchema`**: most common behaviour. When you `use` it,
  Dictator will try to call a `load_resource/1` function by passing the HTTP
  params. This function is overridable, along with `can?/3`
- **`Dictator.Policies.BelongsTo`**: abstraction on top of
  `Dictator.Policies.EctoSchema`, for the most common use case: when a user
  wants to read and write resources they own, but read access is provided to
  everyone else. This policy makes some assumptions regarding your
  implementation, all of those highly customisable.
- **`Dictator.Policy`**: most basic policy possible. `use` it if you don't want
  to load resources from the database (e.g to check if a user has an `is_admin`
  field set to `true`)

#### Dictator.Policies.EctoSchema

Most common behaviour. When you `use` it, Dictator will try to call a
`load_resource/1` function by passing the HTTP params. This allows you to access
the resource in the third parameter of `can/3?`. The `load_resource/1` function
is overridable, along with `can?/3`.

Take the following example:

```elixir
defmodule ClientWeb.Policies.Thing do
  alias Client.Context.Thing

  use Dictator.Policies.EctoSchema, for: Thing

  # User can edit, update, delete and show their own things
  def can?(%User{id: user_id}, action, %{resource: %Thing{user_id: user_id}})
    when action in [:edit, :update, :delete, :show], do: true

  # Any user can index, new and create things
  def can?(_, action, _) when action in [:index, :new, :create], do: true

  # Users can't do anything else (users editing, updating, deleting and showing)
  # on things they don't own
  def can?(_, _, _), do: false
end
```

In the example above, Dictator takes care of loading the `Thing` resource
through the HTTP params. However, you might want to customise the way the
resource is loaded. To do that, you should override the `load_resource/1`
function.

As an example:

```elixir
defmodule ClientWeb.Policies.Thing do
  alias Client.Context.Thing

  use Dictator.Policies.EctoSchema, for: Thing

  def load_resource(%{"owner_id" => owner_id, "uuid" => uuid}) do
    ClientWeb.Repo.get_by(Thing, owner_id: owner_id, uuid: uuid)
  end

  def can?(_, action, _) when action in [:index, :show, :new, :create], do: true

  def can?(%{id: owner_id}, action, %{resource: %Thing{owner_id: owner_id}})
    when action in [:edit, :update, :delete],
    do: true

  def can?(_user, _action, _params), do: false
end
```

The following custom options are available:

- **`key`**: defaults to `:id`, primary key of the resource being accessed.
- **`repo`**: overrides the repo set by the config.

#### Dictator.Policies.BelongsTo

Policy definition commonly used in typical `belongs_to` associations. It is an
abstraction on top of `Dictator.Policies.EctoSchema`.

This policy assumes the users can read (`:show`, `:index`, `:new`,
`:create`) any information but only write (`:edit`, `:update`, `:delete`)
their own.

As an example, in a typical Twitter-like application, a user `has_many`
posts and a post `belongs_to` a user. You can define a policy to let users
manage their own posts but read all others by doing the following:

```elixir
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

```elixir
defmodule MyAppWeb.Policies.Post do
  use Dictator.Policies.BelongsTo, for: MyApp.Post
end
```

The assumptions made are that:

- your resource has a `user_id` foreign key (you can change this with the
  `:foreign_key` option)
- your user has an `id` primary key (you can change this with the `:owner_id`
  option)

If your user has a `uuid` primary key and the post identifies the user through a
`:poster_id` foreign key, you can do the following:

```elixir
defmodule MyAppWeb.Policies.Post do
  use Dictator.Policies.BelongsTo, for: MyApp.Post,
    foreign_key: :poster_id, owner_id: :uuid
end
```

The `key` and `repo` options supported by `Dictator.Policies.EctoSchema` are
also supported by `Dictator.Policies.BelongsTo`.

### Plug Options

`plug Dictator` supports 3 options:

- **only/except:** (optional) - actions subject to authorization.
- **policy:** (optional, infers the policy) - policy to be used
- **resource\_key:** (optional, default: `:current_user`) - key to use in the
  conn.assigns to load the currently logged in resource.

#### Limitting the actions to be authorized

If you want to only limit authorization to a few actions you can use the `:only`
or `:except` options when calling the plug in your controller:

```elixir
defmodule ClientWeb.ThingController do
  use ClientWeb, :controller

  plug Dictator, only: [:create, :update, :delete]
  # plug Dictator, except: [:show, :index, :new, :edit]

  # ...
end
```

In both cases, all other actions will not go through the authorization plug and
the policy will only be enforced for the `create`,`update` and `delete` actions.

#### Overriding the policy to be used

By default, the plug will automatically infer the policy to be used.
`MyWebApp.UserController` would mean a `MyWebApp.Policies.User` policy to use.

However, by using the `:policy` option, that can be overriden

```elixir
defmodule ClientWeb.ThingController do
  use ClientWeb, :controller

  plug Dictator, policy: MyPolicy

  # ...
end
```

#### Overriding the current user key

By default, the plug will automatically search for a `current_user` in the
`conn.assigns`. You can change this behaviour by using the `key` option
in the `plug` call. This will override the `key` option set in `config.exs`.

```elixir
defmodule ClientWeb.ThingController do
  use ClientWeb, :controller

  plug Dictator, key: :current_organization

  # ...
end
```

### Configuration Options

Dictator supports three options to be placed in `config/config.exs`:

- **repo** - default repo to be used by `Dictator.Policies.EctoSchema`. If not
  set, you need to define what repo to use in the policy through the `:repo`
  option.
- **key** (optional, defaults to `:key`) - key to be used to find the
  current user in `conn.assigns`.
- **unauthorized\_handler** (optional, default:
  `Dictator.UnauthorizedHandlers.Default`) - module to call to handle
  unauthorisation errors.

#### Setting a default repo

`Dictator.Policies.EctoSchema` requires a repo to be set to load resource from.

It is recommended that you set it in `config/config.exs`:

```elixir
config :dictator, repo: Client.Repo
```

If not configured, it must be provided in each policy. The `repo` option when
`use`-ing the policy takes precedence. So you can also set a custom repo for
certain resources:

```elixir
defmodule ClientWeb.Policies.Thing do
  alias Client.Context.Thing
  alias Client.FunkyRepoForThings

  use Dictator.Policies.BelongsTo, for: Thing, repo: FunkyRepoForThings
end
```

#### Setting a default current user key

By default, the plug will automatically search for a `current_user` in the
`conn.assigns`. The default value is `:current_user` but this can be overriden
by changing the config:

```elixir
config :dictator, key: :current_company
```

The value set by the `key` option when plugging Dictator overrides this one.

#### Setting the unauthorized handler

When a user does not have access to a given resource, an unauthorized handler is
called. By default this is `Dictator.UnauthorizedHandlers.Default` which sends a
simple 401 with the body set to `"you are not authorized to do that"`.

You can also make use of the JSON API compatible
`Dictator.UnauthorizedHandlers.JsonApi` or provide your own:

```elixir
config :dictator, unauthorized_handler: MyUnauthorizedHandler
```

## Contributing

Feel free to contribute.

If you found a bug, open an issue. You can also open a PR for bugs or new
features. Your PRs will be reviewed and subject to our style guide and linters.

All contributions **must** follow the [Code of
Conduct](https://github.com/subvisual/dictator/blob/master/CODE_OF_CONDUCT.md)
and [Subvisual's guides](https://github.com/subvisual/guides).

## Setup

To clone and setup the repo:

```bash
git clone git@github.com:subvisual/dictator.git
cd dictator
bin/setup
```

And everything should automatically be installed for you.

To run the development server:

```bash
bin/server
```

## Other projects

Not your cup of tea? 🍵 Here are some other Elixir alternatives we like:

- [@schrockwell/bodyguard](https://github.com/schrockwell/bodyguard)
- [@jarednorman/canada](https://github.com/jarednorman/canada)
- [@cpjk/canary](https://github.com/cpjk/canary)
- [@boydm/policy_wonk](https://github.com/boydm/policy_wonk)

## About

`Dictator` is maintained by [Subvisual](http://subvisual.com).

[<img alt="Subvisual logo" src="https://raw.githubusercontent.com/subvisual/guides/master/github/templates/subvisual_logo_with_name.png" width="350px" />](https://subvisual.com)
