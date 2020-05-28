defmodule Dictator.PolicyTest do
  use ExUnit.Case

  alias Dictator.Policy

  describe "can?/3" do
    test "defaults to false" do
      refute Dictator.TestPolicy.can?(:whatever, :i, :want)
    end
  end
end
