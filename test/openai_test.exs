defmodule OpenaiTest do
  use ExUnit.Case
  doctest OpenAI

  import Mock

  setup do
    [
      api_key: "123456789"
    ]
  end

  describe "engines" do
    test "success", %{api_key: api_key} do
      with_mock(:hackney)
    end
  end
end
