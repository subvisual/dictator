# Dictator

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `dictator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:dictator, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/dictator](https://hexdocs.pm/dictator).

## Example

`Dictator` assumes you have a `current_user` in your `conn.assigns`. To authorize your users:

```elixir
defmodule ClientWeb.ThingController do
  use ClientWeb, :controller

  plug Dictator.Plug.Authorize
end
```

That plug will automatically look for a `ClientWeb.Policies.Thing` module, which
you can define as

```elixir
defmodule ClientWeb.Policies.Thing do
  alias Client.Context.Thing

  use Dictator.Policy, for: Thing

  # User can edit, update, delete and show their own things
  def can?(%User{id: user_id}, action, %Thing{user_id: user_id})
    when action in [:edit, :update, :delete, :show], do: true

  # Any user can index, new and create things
  def can?(_, action, _) when action in [:index, :new, :create], do: true

  # Users can't do anything else (users editing, updating, deleting and showing)
  # on things they don't own
  def can?(_, _, _), do: false
end
```

This scenario is, in fact, so common that already comes bundled as
`Dictator.Policies.BasicPolicy`.

```elixir
defmodule ClientWeb.Policies.Thing do
  alias Client.Context.Thing

  use Dictator.BasicPolicy, for: Thing
end
```

### Custom Options

By `use`ing `Dictator.Policy`, it will automatically infer the correct repo and
fail if it cannot do so. In those scenarios you need to pass the repo:

```elixir
defmodule ClientWeb.Policies.Thing do
  alias Client.Context.Thing
  alias Client.FunkyRepoForThings

  use Dictator.BasicPolicy, for: Thing, repo: FunkyRepoForThings
end
```

By default, it calls `YourRepo.get_by(YourModule, id: id)`. But if you use a
different primary key, you can set that by overriding the `key` option:

```elixir
defmodule ClientWeb.Policies.Thing do
  alias Client.Context.Thing

  use Dictator.BasicPolicy, for: Thing, key: :uuid
end
```

If you need further customizing how the resource is loaded from the database,
you can override `load_resource/1` which will pass along the route params.

```elixir
defmodule ClientWeb.Policies.Thing do
  alias Client.Context.Thing
  alias Client.FunkyRepoForThings

  use Dictator.BasicPolicy, for: Thing

  def load_resource(params) do
    if params["uuid"] && params["name"] do
      FunkyRepoForThings.get_by(Thing, uuid: params["uuid"], name: [params["name"]])
    else
      FunkyRepoForThings.get(Thing, params["id"])
    end
  end
end
```
