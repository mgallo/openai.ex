defmodule OpenAI.StreamTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, url: "http://localhost:#{bypass.port}"}
  end

  describe "new/1" do
    test "handles error" do
      results =
        OpenAI.Stream.new(fn ->
          HTTPoison.get("http://nxdomain-error/", [], stream_to: self(), async: :once)
        end)
        |> Enum.to_list()

      assert [%{"reason" => :nxdomain, "status" => :error}] == results
    end

    test "handles chunked event stream", %{bypass: bypass, url: url} do
      Bypass.expect(bypass, "GET", "/", fn conn ->
        conn =
          conn
          |> Plug.Conn.put_resp_header("content-type", "text/event-stream")
          |> Plug.Conn.send_chunked(200)

        Plug.Conn.chunk(conn, ~s|data: {"id":"chatcmpl-01","object":"chat.completion.chunk","created":0,"model":"gpt-3.5-turbo-0125","system_fingerprint":"fp_deadbeef","choices":[{"index":0,"delta":{"content":" The"},"logprobs":null,"finish_reason":null}]}\n\n|)

        Plug.Conn.chunk(conn, ~s|data: {"id":"chatcmpl-02","object":"chat.completion.chunk","created":0,"model":"gpt-3.5-turbo-0125","system_fingerprint":"fp_deadbeef","choices":[{"index":0,"delta":{"content":" Test"},"logprobs":null,"finish_reason":null}]}\n\ndata: {"id":"chatcm|)

        Plug.Conn.chunk(conn, ~s|pl-03","object":"chat.completion.chunk","created":0,"model":"gpt-3.5-turbo-0125","system_fingerprint":"fp_deadbeef","choices":[{"index":0,"delta":{},"logprobs":null,"finish_reason":"stop"}]}\n\ndata: [DONE]|)

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
