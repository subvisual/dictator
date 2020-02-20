defmodule DictatorTest do
  use ExUnit.Case
  doctest Dictator

  test "greets the world" do
    assert Dictator.hello() == :world
  end
end
