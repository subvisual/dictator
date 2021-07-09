defmodule Dictator.NotFoundHandlers.DefaultTest do
  use ExUnit.Case
  use Plug.Test

  alias Dictator.NotFoundHandlers.Default

  describe "call/2" do
    test "sets a 404 response" do
      result = conn(:get, "/") |> Default.call([])

      assert result.status == 404
    end

    test "sets a response body" do
      result = conn(:get, "/") |> Default.call([])

      assert is_binary(result.resp_body)
    end
  end
end
