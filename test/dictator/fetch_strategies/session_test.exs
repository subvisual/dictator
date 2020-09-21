defmodule Dictator.FetchStrategies.SessionTest do
  use ExUnit.Case
  use Plug.Test

  alias Dictator.FetchStrategies.Session

  describe "fetch/2" do
    test "retrieves the key from the session" do
      conn =
        conn(:get, "/", nil)
        |> init_test_session(%{})
        |> put_session(:current_user, %{id: 1})

      assert %{id: 1} = Session.fetch(conn, :current_user)
    end
  end
end
