defmodule Dictator.ConfigTest do
  use ExUnit.Case

  alias Dictator.Config

  setup do
    default = Application.get_env(:dictator, :foo)
    Application.put_env(:dictator, :foo, :bar)

    on_exit(fn ->
      Application.put_env(:dictator, :foo, default)
    end)
  end

  describe "get/2" do
    test "fetches keys from the application's env" do
      assert Config.get(:foo) == :bar
    end

    test "defaults to nil" do
      assert Config.get(:baz) == nil
    end

    test "accepts a fallback value" do
      assert Config.get(:baz, :biz) == :biz
    end
  end
end
