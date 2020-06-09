defmodule Dictator.Policy do
  @moduledoc """
  Policy behaviour definition.

  If your Policy requires the resource to be loaded (e.g. if you want a `Post`
  to be loaded when users are trying to `GET "/posts/1"`), `use
  Dictator.Policies.EctoSchema` instead.

  The most basic policies need only to implement the `c:can?/3` callback.
  """

  @doc """
  Callback invoked to check if the current user is authorised to perform a
  given action.

  The most basic policies need only to implement this callback. This function
  receives the current user as the first parameter, the action to be performed
  as the second (e.g. `:show`) and finally a map containing the following keys:

  * `:resource` - if it has been loaded.
  * `:params` - the HTTP params.
  * `:opts` - options passed to the plug.
  """
  @callback can?(map() | struct(), atom(), map()) :: bool()

  defmacro __using__(_opts) do
    quote do
      @behaviour Dictator.Policy
    end
  end
end
