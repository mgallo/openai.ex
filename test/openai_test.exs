defmodule OpenAITest do
  use ExUnit.Case
  doctest OpenAI

  setup do
    [
      api_key: "123456789"
    ]
  end

  describe "engines" do
  end
end
