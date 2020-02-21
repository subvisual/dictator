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

  describe "for :foreign_key and :owner_key overrides" do
    alias Dictator.Test.StandardWithDifferentKeys.{
      Policy,
      Struct
    }

    test "is true for :index, :new and :create" do
      assert Policy.can?(nil, :index, nil)
      assert Policy.can?(nil, :new, nil)
      assert Policy.can?(nil, :create, nil)
    end

    test "is true for :edit, :update, :delete, :show if the user owns the resource" do
      struct = %Struct{id: 1, organization_id: 1}

      assert Policy.can?(%{slug: 1}, :edit, struct)
      assert Policy.can?(%{slug: 1}, :update, struct)
      assert Policy.can?(%{slug: 1}, :delete, struct)
      assert Policy.can?(%{slug: 1}, :show, struct)
    end

    test "is false in any other scenario" do
      struct = %Struct{id: 1, organization_id: 2}

      refute Policy.can?(%{slug: 1}, :edit, struct)
      refute Policy.can?(%{slug: 1}, :update, struct)
      refute Policy.can?(%{slug: 1}, :delete, struct)
      refute Policy.can?(%{slug: 1}, :show, struct)
    end
  end
end
