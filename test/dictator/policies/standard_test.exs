defmodule Dictator.Policies.StandardTest do
  use ExUnit.Case

  alias Dictator.Test.Standard

  describe "can?/3" do
    test "is true for :index, :new and :create" do
      assert Standard.Policy.can?(nil, :index, nil)
      assert Standard.Policy.can?(nil, :new, nil)
      assert Standard.Policy.can?(nil, :create, nil)
    end

    test "is true for :edit, :update, :delete, :show if the user owns the resource" do
      struct = %Standard.Struct{id: 1, user_id: 1}

      assert Standard.Policy.can?(%{id: 1}, :edit, struct)
      assert Standard.Policy.can?(%{id: 1}, :update, struct)
      assert Standard.Policy.can?(%{id: 1}, :delete, struct)
      assert Standard.Policy.can?(%{id: 1}, :show, struct)
    end

    test "is false in any other scenario" do
      struct = %Standard.Struct{id: 1, user_id: 2}

      refute Standard.Policy.can?(%{id: 1}, :edit, struct)
      refute Standard.Policy.can?(%{id: 1}, :update, struct)
      refute Standard.Policy.can?(%{id: 1}, :delete, struct)
      refute Standard.Policy.can?(%{id: 1}, :show, struct)
    end
  end
end
