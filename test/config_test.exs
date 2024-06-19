defmodule OpenAI.ConfigTest do
  use ExUnit.Case
  alias OpenAI.Config
  alias OpenAI.Client

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

  test "api_url option is recognized" do
    assert Config.api_url() == "https://api.openai.com"

    Application.put_env(@application, :api_url, "http://localhost:8080")
    assert Config.api_url() == "http://localhost:8080"
    assert Client.process_request_url("/api") == "http://localhost:8080/api"
  end

  defp reset_env() do
    Application.get_all_env(@application)
    |> Keyword.keys()
    |> Enum.each(&Application.delete_env(@application, &1))
  end
end
