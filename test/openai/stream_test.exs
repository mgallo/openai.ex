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

    test "handles OpenAI malformed error", %{bypass: bypass, url: url} do
      Bypass.expect(bypass, "GET", "/", fn conn ->
        conn =
          conn
          |> Plug.Conn.put_resp_header("content-type", "text/event-stream")
          |> Plug.Conn.send_chunked(400)

        Plug.Conn.chunk(conn, "{\n")
        Plug.Conn.chunk(conn, ~s|"error": {\n|)

        Plug.Conn.chunk(
          conn,
          ~s|"message": "The model `gpt-3.5` does not exist or you do not have access to it.",\n|
        )

        Plug.Conn.chunk(conn, ~s|"type": "invalid_request_error",\n|)
        Plug.Conn.chunk(conn, ~s|"param": null,\n|)
        Plug.Conn.chunk(conn, ~s|"code": "model_not_found"\n|)
        Plug.Conn.chunk(conn, "}\n")
        Plug.Conn.chunk(conn, "}\n")

        conn
      end)

      results =
        OpenAI.Stream.new(fn ->
          HTTPoison.get(url, [], stream_to: self(), async: :once)
        end)
        |> Enum.to_list()

      assert [
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

    test "handles stream with event name", %{bypass: bypass, url: url} do
      Bypass.expect(bypass, "GET", "/", fn conn ->
        conn =
          conn
          |> Plug.Conn.put_resp_header("content-type", "text/event-stream")
          |> Plug.Conn.send_chunked(200)

        Plug.Conn.chunk(
          conn,
          ~s|event: thread.run.created\ndata: {"id":"run_01","object":"thread.run","created_at":1721218990,"assistant_id":"asst_01","thread_id":"thread_01","status":"queued","started_at":null,"expires_at":1721219590,"cancelled_at":null,"failed_at":null,"completed_at":null,"required_action":null,"last_error":null,"model":"gpt-4o","instructions":"content","tools":[],"tool_resources":{"code_interpreter":{"file_ids":[]}},"metadata":{},"temperature":0.01,"top_p":1.0,"max_completion_tokens":null,"max_prompt_tokens":null,"truncation_strategy":{"type":"auto","last_messages":null},"incomplete_details":null,"usage":null,"response_format":"auto","tool_choice":"auto","parallel_tool_calls":true}\n\n|
        )
      end)

      results =
        OpenAI.Stream.new(fn ->
          HTTPoison.get(url, [], stream_to: self(), async: :once)
        end)
        |> Enum.to_list()

      assert [
               %{
                 "assistant_id" => "asst_01",
                 "cancelled_at" => nil,
                 "completed_at" => nil,
                 "created_at" => 1_721_218_990,
                 "expires_at" => 1_721_219_590,
                 "failed_at" => nil,
                 "id" => "run_01",
                 "incomplete_details" => nil,
                 "instructions" => "content",
                 "last_error" => nil,
                 "max_completion_tokens" => nil,
                 "max_prompt_tokens" => nil,
                 "metadata" => %{},
                 "model" => "gpt-4o",
                 "object" => "thread.run",
                 "parallel_tool_calls" => true,
                 "required_action" => nil,
                 "response_format" => "auto",
                 "started_at" => nil,
                 "status" => "queued",
                 "temperature" => 0.01,
                 "thread_id" => "thread_01",
                 "tool_choice" => "auto",
                 "tool_resources" => %{"code_interpreter" => %{"file_ids" => []}},
                 "tools" => [],
                 "top_p" => 1.0,
                 "truncation_strategy" => %{"last_messages" => nil, "type" => "auto"},
                 "usage" => nil
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
