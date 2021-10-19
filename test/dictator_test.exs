defmodule DictatorTest do
  use ExUnit.Case, async: true

  alias Dictator.Test.MessageSending

  describe "call/2" do
    test "uses the correct policy" do
      conn = build_conn()

      Dictator.call(conn, [])

      assert_receive {:can?, %{id: 1}, :show, %{resource: _}}
    end

    test "loads the correct resource" do
      conn = build_conn()

      Dictator.call(conn, [])

      assert_receive {:get_by, MessageSending.Struct, [id: 1]}
    end

    test "401s if the user is not authorized" do
      conn = build_conn(user: %{id: 2})

      response = Dictator.call(conn, [])

      assert response.status == 401
    end

    test "loads phoenix_action from conn" do
      conn = build_conn(action: :show)

      Dictator.call(conn, [])

      assert_receive {:can?, _, :show, _}
    end
  end

  describe "call/2 with the :policy option" do
    test "uses the given policy" do
      defmodule MyPolicy do
        use Dictator.Policy, for: MessageSending.Struct, repo: MessageSending.Repo

        def can?(_, _, _) do
          send(self(), __MODULE__)
          true
        end
      end

      conn = build_conn()

      Dictator.call(conn, policy: MyPolicy)

      assert_receive MyPolicy
    end
  end

  describe "call/2 with the :only option" do
    test "checks the policy if action is included" do
      conn = build_conn(action: :show)

      Dictator.call(conn, only: [:show])

      assert_receive {:can?, %{id: 1}, :show, %{resource: _}}
    end

    test "does nothing if the action is not included" do
      conn = build_conn(action: :show)

      bypassed_conn = Dictator.call(conn, only: [:index])

      assert conn == bypassed_conn
    end
  end

  describe "call/2 with the :except option" do
    test "uses the policy if the action is not included" do
      conn = build_conn(action: :show)

      Dictator.call(conn, except: [:index])

      assert_receive {:can?, %{id: 1}, :show, %{resource: _}}
    end

    test "does nothing if the action is included" do
      conn = build_conn(action: :show)

      bypassed_conn = Dictator.call(conn, except: [:show])

      assert conn == bypassed_conn
    end
  end

  describe "call/2 with the :unauthorized_handler option" do
    test "uses the handled passed to options" do
      conn = build_conn(action: :show)

      result = Dictator.call(conn, unauthorized_handler: Dictator.UnauthorizedHandlers.JsonApi)

      content_type = Enum.find(result.resp_headers, &(elem(&1, 0) == "content-type")) |> elem(1)

      assert content_type == "application/json"
    end

    test "uses the default from config when :unauthorized_handler option is not passed" do
      conn = build_conn(action: :show)

      result = Dictator.call(conn, [])

      assert result.status == 401
    end
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
