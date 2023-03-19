defmodule OpenAi.ConfigTest do
  use ExUnit.Case
  alias OpenAI.Config

  @application :openai

  setup_all do
    reset_env()
    on_exit(&reset_env/0)
  end

  test "http_options/0 should return value or default" do
    assert Config.http_options() == []

    Application.put_env(@application, :http_options, recv_timeout: 30_000)
    assert Config.http_options() == [recv_timeout: 30_000]
  end

  defp reset_env() do
    Application.get_all_env(@application)
    |> Keyword.keys()
    |> Enum.each(&Application.delete_env(@application, &1))
  end
end
