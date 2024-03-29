defmodule OpenAI.StreamTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, url: "http://localhost:#{bypass.port}"}
  end

  describe "new/1" do
    test "handles connection error" do
      results =
        OpenAI.Stream.new(fn ->
          HTTPoison.get("http://nxdomain-error/", [], stream_to: self(), async: :once)
        end)
        |> Enum.to_list()

      assert [%{"reason" => :nxdomain, "status" => :error}] == results
    end

    test "handles OpenAI error", %{bypass: bypass, url: url} do
      Bypass.expect(bypass, "GET", "/", fn conn ->
        conn =
          conn
          |> Plug.Conn.put_resp_header("content-type", "text/event-stream")
          |> Plug.Conn.send_chunked(400)

        Plug.Conn.chunk(
          conn,
          ~s|{\n    "error": {\n        "message": "The model `gpt-3.5` does not exist or you do not have access to it.",\n        "type": "invalid_request_error",\n        "param": null,\n        "code": "model_not_found"\n    }\n}\n|
        )

        conn
      end)

      results =
        OpenAI.Stream.new(fn ->
          HTTPoison.get(url, [], stream_to: self(), async: :once)
        end)
        |> Enum.to_list()

      assert [
               %{"choices" => [], "code" => 400, "status" => :error},
               %{
                 "error" => %{
                   "code" => "model_not_found",
                   "message" =>
                     "The model `gpt-3.5` does not exist or you do not have access to it.",
                   "param" => nil,
                   "type" => "invalid_request_error"
                 }
               }
             ] == results
    end

    test "handles chunked event stream", %{bypass: bypass, url: url} do
      Bypass.expect(bypass, "GET", "/", fn conn ->
        conn =
          conn
          |> Plug.Conn.put_resp_header("content-type", "text/event-stream")
          |> Plug.Conn.send_chunked(200)

        Plug.Conn.chunk(
          conn,
          ~s|data: {"id":"chatcmpl-01","object":"chat.completion.chunk","created":0,"model":"gpt-3.5-turbo-0125","system_fingerprint":"fp_deadbeef","choices":[{"index":0,"delta":{"content":" The"},"logprobs":null,"finish_reason":null}]}\n\n|
        )

        Plug.Conn.chunk(
          conn,
          ~s|data: {"id":"chatcmpl-02","object":"chat.completion.chunk","created":0,"model":"gpt-3.5-turbo-0125","system_fingerprint":"fp_deadbeef","choices":[{"index":0,"delta":{"content":" Test"},"logprobs":null,"finish_reason":null}]}\n\ndata: {"id":"chatcm|
        )

        Plug.Conn.chunk(
          conn,
          ~s|pl-03","object":"chat.completion.chunk","created":0,"model":"gpt-3.5-turbo-0125","system_fingerprint":"fp_deadbeef","choices":[{"index":0,"delta":{},"logprobs":null,"finish_reason":"stop"}]}\n\ndata: [DONE]|
        )

        conn
      end)

      results =
        OpenAI.Stream.new(fn ->
          HTTPoison.get(url, [], stream_to: self(), async: :once)
        end)
        |> Enum.to_list()

      assert [
               %{
                 "id" => "chatcmpl-01",
                 "object" => "chat.completion.chunk",
                 "created" => 0,
                 "model" => "gpt-3.5-turbo-0125",
                 "system_fingerprint" => "fp_deadbeef",
                 "choices" => [
                   %{
                     "index" => 0,
                     "delta" => %{"content" => " The"},
                     "logprobs" => nil,
                     "finish_reason" => nil
                   }
                 ]
               },
               %{
                 "id" => "chatcmpl-02",
                 "object" => "chat.completion.chunk",
                 "created" => 0,
                 "model" => "gpt-3.5-turbo-0125",
                 "system_fingerprint" => "fp_deadbeef",
                 "choices" => [
                   %{
                     "index" => 0,
                     "delta" => %{"content" => " Test"},
                     "logprobs" => nil,
                     "finish_reason" => nil
                   }
                 ]
               },
               %{
                 "id" => "chatcmpl-03",
                 "object" => "chat.completion.chunk",
                 "created" => 0,
                 "model" => "gpt-3.5-turbo-0125",
                 "system_fingerprint" => "fp_deadbeef",
                 "choices" => [
                   %{
                     "index" => 0,
                     "delta" => %{},
                     "logprobs" => nil,
                     "finish_reason" => "stop"
                   }
                 ]
               }
             ] == results
    end
  end
end
