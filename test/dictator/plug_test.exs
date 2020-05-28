defmodule Dictator.PlugTest do
  use ExUnit.Case, async: true

  alias Dictator.Test.MessageSending

  describe "call/2" do
    test "uses the correct policy" do
      conn = build_conn()

      Dictator.Plug.call(conn, [])

      assert_receive {:can?, %{id: 1}, :show, %{resource: _}}
    end

    test "loads the correct resource" do
      conn = build_conn()

      Dictator.Plug.call(conn, [])

      assert_receive {:get_by, MessageSending.Struct, [id: 1]}
    end

    test "accepts a custom policy via the :policy option" do
      defmodule MyPolicy do
        use Dictator.Policy, for: MessageSending.Struct, repo: MessageSending.Repo

        def can?(_, _, _) do
          send(self(), __MODULE__)
          true
        end
      end

      conn = build_conn()

      Dictator.Plug.call(conn, policy: MyPolicy)

      assert_receive MyPolicy
    end

    test "401s if the user is not authorized" do
      conn = build_conn(user: %{id: 2})

      response = Dictator.Plug.call(conn, [])

      assert response.status == 401
    end

    defp build_conn(opts \\ []) do
      action = opts[:action] || :show
      controller = opts[:controller] || MessageSending.SampleController
      user = opts[:user] || %{id: 1}
      id = opts[:id] || 1

      Plug.Test.conn(:get, "/", %{id: id})
      |> Plug.Conn.put_req_header("content-type", "application/json")
      |> Plug.Conn.put_private(:phoenix_action, action)
      |> Plug.Conn.put_private(:phoenix_controller, controller)
      |> Plug.Conn.assign(:current_user, user)
    end
  end
end
