defmodule Dictator.PolicyTest do
  use ExUnit.Case

  alias Dictator.Policy

  describe "infer_repo_for/1" do
    test "infers the repo based on the namespace" do
      defmodule Thing do
      end

      assert Dictator.Repo = Policy.infer_repo_for(Thing)
    end

    test "infers the repo based on the config when namespacing isn't possible" do
      config = Application.get_env(:dictator, :ecto_repos)
      Application.put_env(:dictator, :ecto_repos, [TopLevelRepo])

      assert TopLevelRepo = Policy.infer_repo_for(Test.Resource)

      Application.put_env(:dictator, :ecto_repos, config)
    end
  end

  describe "can?/3" do
    test "defaults to true" do
      assert Dictator.TestPolicy.can?(:whatever, :i, :want)
    end
  end

  describe "load_resource/1" do
    alias Dictator.TestPolicy

    test "is nil when there are no params" do
      refute TestPolicy.load_resource(nil)
      refute TestPolicy.load_resource(%{})
    end

    test "is nil when the param isn't on the params hash" do
      refute TestPolicy.load_resource(%{"other" => "param"})
    end

    test "gets the resource from the repo" do
      assert {:ok, TestPolicy} = TestPolicy.load_resource(%{"id" => 1})
    end

    test "gets the params with indifferent access" do
      assert {:ok, TestPolicy} = TestPolicy.load_resource(%{id: 1})
    end

    test "allos the `key` param to set the resource key" do
      assert {:ok, TestPolicy.WithOtherKey} =
               TestPolicy.WithOtherKey.load_resource(%{"other" => 1})
    end
  end
end
