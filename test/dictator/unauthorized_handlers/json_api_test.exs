defmodule Dictator.UnauthorizedHandlers.JsonApiTest do
  use ExUnit.Case
  use Plug.Test

  alias Dictator.UnauthorizedHandlers.JsonApi

  describe "call/2" do
    test "sets a 401 response" do
      result = conn(:get, "/") |> JsonApi.call([])

      assert result.status == 401
    end

    test "sets an empty JSON response body" do
      result = conn(:get, "/") |> JsonApi.call([])

      assert result.resp_body == "{}"
    end

    test "sets a json content-type" do
      result = conn(:get, "/") |> JsonApi.call([])

      content_type = Enum.find(result.resp_headers, &(elem(&1, 0) == "content-type")) |> elem(1)

      assert content_type == "application/json"
    end
  end
end
