defmodule Dictator.Policies.BelongsToTest do
  use ExUnit.Case

  alias Dictator.Test.BelongsTo

  describe "can?/3" do
    test "is true for :index, :show, :new and :create" do
      assert BelongsTo.Policy.can?(nil, :index, nil)
      assert BelongsTo.Policy.can?(nil, :show, nil)
      assert BelongsTo.Policy.can?(nil, :new, nil)
      assert BelongsTo.Policy.can?(nil, :create, nil)
    end

    test "is true for :edit, :update, :delete, :show if the user owns the resource" do
      user = %{id: 1}
      struct = %BelongsTo.Struct{id: 1, user_id: 1}

      assert BelongsTo.Policy.can?(user, :edit, %{resource: struct})
      assert BelongsTo.Policy.can?(user, :update, %{resource: struct})
      assert BelongsTo.Policy.can?(user, :delete, %{resource: struct})
      assert BelongsTo.Policy.can?(user, :show, %{resource: struct})
    end

    test "is false in any other scenario" do
      user = %{id: 1}
      struct = %BelongsTo.Struct{id: 1, user_id: 2}

      refute BelongsTo.Policy.can?(user, :edit, %{resource: struct})
      refute BelongsTo.Policy.can?(user, :update, %{resource: struct})
      refute BelongsTo.Policy.can?(user, :delete, %{resource: struct})
    end
  end

  describe "for :foreign_key and :owner_key overrides" do
    alias Dictator.Test.BelongsToWithDifferentKeys.{
      Policy,
      Struct
    }

    test "is true for :index, :new and :create" do
      assert Policy.can?(nil, :index, nil)
      assert Policy.can?(nil, :show, nil)
      assert Policy.can?(nil, :new, nil)
      assert Policy.can?(nil, :create, nil)
    end

    test "is true for :edit, :update, :delete, :show if the user owns the resource" do
      user = %{slug: 1}
      struct = %Struct{id: 1, organization_id: 1}

      assert Policy.can?(user, :edit, %{resource: struct})
      assert Policy.can?(user, :update, %{resource: struct})
      assert Policy.can?(user, :delete, %{resource: struct})
    end

    test "is false in any other scenario" do
      user = %{slug: 1}
      struct = %Struct{id: 1, organization_id: 2}

      refute Policy.can?(user, :edit, %{resource: struct})
      refute Policy.can?(user, :update, %{resource: struct})
      refute Policy.can?(user, :delete, %{resource: struct})
    end
  end
end
