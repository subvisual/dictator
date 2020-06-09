# Upgrade Guide

## `v0.X` -> `v1.0`

To keep your app working as it is:

* `plug Dictator.Plug.Authorize` is now `plug Dictator`.
* Plug `:resource_key` option has been renamed to `:key`.
* `Dictator.Policy` no longer loads the resource by default. To do so, use
  `Dictator.Policies.EctoSchema`.
* `Dictator.Policy` is now a behaviour. Change it to `@behaviour Dictator.Policy`.
* The third parameter in `can?/3` functions is no longer the resource but a map
  with the `:params`, `:resource` and `:opts` keys. If you are pattern matching
  on `can?(_, _, %Post{})` change it to `can?(_, _ %{resource: %Post{}})`.
* The `Ecto.Repo` is no longer inferred. Instead, use the `:repo` option
  explicitly or set it via `config :dictator, repo: MyRepo`
* `Dictator.Policies.Standard` has been renamed to `Dictator.Policies.BelongsTo`.

Other upgrades:
* The plug is now available for both controllers and router pipelines.
* Plug `:only` option now allows non-standard methods.
* Plug `:except` option added.
* You can now configure how you want the response to be sent by using the
  `:unauthorized_handler` option
