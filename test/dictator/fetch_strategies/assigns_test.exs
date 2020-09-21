defmodule Dictator.FetchStrategies.AssignsTest do
  use ExUnit.Case
  use Plug.Test

  alias Dictator.FetchStrategies.Assigns

  describe "fetch/2" do
    test "retrieves the key from the conn assigns" do
      conn =
        conn(:get, "/", nil)
        |> assign(:current_user, %{id: 1})

      assert %{id: 1} = Assigns.fetch(conn, :current_user)
    end
  end
end
