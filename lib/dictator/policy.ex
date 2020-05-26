defmodule Dictator.Policy do
  @callback can?(map(), atom(), map()) :: bool()
  @callback resourceful?() :: bool()

  @optional_callbacks can?: 3, resourceful?: 0
end
