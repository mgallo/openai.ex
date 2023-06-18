defmodule OpenAI.ClientTest do
  use ExUnit.Case

  describe "handle_response/1" do
    test "it should respond with success if HTTP status code 200 and the response is a JSON" do
      res =
        {:ok,
         %HTTPoison.Response{
           body:
             {:ok,
              %{
                "text" =>
                  "I've seen things you people wouldn't believe. Attack ships on fire off the shoulder of a lion. I watched sea beans glitter in the darkness for ten hours a day."
              }},
           headers: [],
           request: %HTTPoison.Request{
             body: "",
             headers: [],
             method: :get,
             options: [],
             params: %{},
             url: "https://api.openai.com/v1/audio/transcriptions"
           },
           request_url: "https://api.openai.com/v1/audio/transcriptions",
           status_code: 200
         }}
        |> OpenAI.Client.handle_response()

      assert {:ok,
              %{
                text:
                  "I've seen things you people wouldn't believe. Attack ships on fire off the shoulder of a lion. I watched sea beans glitter in the darkness for ten hours a day."
              }} = res
    end

    test "it should respond with success if HTTP status code 200 and the response is srt/vtt format" do
      res =
        {:ok,
         %HTTPoison.Response{
           body:
             "1\n00:00:00,000 --> 00:00:07,000\nI've seen things you people wouldn't believe.\n\n2\n00:00:08,000 --> 00:00:12,000\nAttack ships on fire off the shoulder of a lion.\n\n3\n00:00:12,000 --> 00:00:29,000\nI watched sea beans glitter in the darkness for ten hours a day.\n\n\n",
           headers: [],
           request: %HTTPoison.Request{
             body: {:multipart, []},
             headers: [],
             method: :post,
             options: [],
             params: %{},
             url: "https://api.openai.com/v1/audio/transcriptions"
           },
           request_url: "https://api.openai.com/v1/audio/transcriptions",
           status_code: 200
         }}
        |> OpenAI.Client.handle_response()

      assert {:ok,
              "1\n00:00:00,000 --> 00:00:07,000\nI've seen things you people wouldn't believe.\n\n2\n00:00:08,000 --> 00:00:12,000\nAttack ships on fire off the shoulder of a lion.\n\n3\n00:00:12,000 --> 00:00:29,000\nI watched sea beans glitter in the darkness for ten hours a day.\n\n\n"} =
               res
    end

    test "it should handle json errors (HTTP Error code 404)" do
      res =
        {:ok,
         %HTTPoison.Response{
           body:
             {:ok,
              %{
                "error" => %{
                  "code" => nil,
                  "message" => "No such File object: asd",
                  "param" => "id",
                  "type" => "invalid_request_error"
                }
              }},
           headers: [],
           request: %HTTPoison.Request{
             body: "",
             headers: [],
             method: :get,
             options: [],
             params: %{},
             url: "https://api.openai.com/v1/files/asd"
           },
           request_url: "https://api.openai.com/v1/files/asd",
           status_code: 404
         }}
        |> OpenAI.Client.handle_response()

      assert {:error,
              %{
                "error" => %{
                  "code" => nil,
                  "message" => "No such File object: asd",
                  "param" => "id",
                  "type" => "invalid_request_error"
                }
              }} = res
    end

    test "it should handle json errors (HTTP Error code 400)" do
      res =
        {:ok,
         %HTTPoison.Response{
           body:
             {:ok,
              %{
                "error" => %{
                  "code" => nil,
                  "message" => "you must provide a model parameter",
                  "param" => nil,
                  "type" => "invalid_request_error"
                }
              }},
           headers: [],
           request: %HTTPoison.Request{
             body:
               {:multipart,
                [
                  {:file, "./config/bladerunner.mp3",
                   {"form-data", [name: "file", filename: "bladerunner.mp3"]}, []},
                  {"models", "whisper-1"},
                  {"response_formats", "srt"}
                ]},
             headers: [],
             method: :post,
             options: [],
             params: %{},
             url: "https://api.openai.com/v1/audio/transcriptions"
           },
           request_url: "https://api.openai.com/v1/audio/transcriptions",
           status_code: 400
         }}
        |> OpenAI.Client.handle_response()

      assert {:error,
              %{
                "error" => %{
                  "code" => nil,
                  "message" => "you must provide a model parameter",
                  "param" => nil,
                  "type" => "invalid_request_error"
                }
              }} = res
    end

    test "it should handle html errors (sometimes openai answer with HTTP Error code 502 and cloudflare / nginx error)" do
      res =
        {:ok,
         %HTTPoison.Response{
           body:
             "<html>\r\n<head><title>502 Bad Gateway</title></head>\r\n<body>\r\n<center><h1>502 Bad Gateway</h1></center>\r\n<hr><center>cloudflare</center>\r\n</body>\r\n</html>\r\n",
           status_code: 502
         }}
        |> OpenAI.Client.handle_response()

      assert {:error,
              %{
                body:
                  "<html>\r\n<head><title>502 Bad Gateway</title></head>\r\n<body>\r\n<center><h1>502 Bad Gateway</h1></center>\r\n<hr><center>cloudflare</center>\r\n</body>\r\n</html>\r\n",
                status_code: 502
              }} = res
    end

    test "it should handle 503 nginx errors (sometimes openai answer with HTTP Error code 503)" do
      res =
        {:ok,
         %HTTPoison.Response{
           status_code: 503,
           body:
             {:error,
              {:unexpected_token,
               "<html>\r\n<head><title>503 Service Temporarily Unavailable</title></head>\r\n<body>\r\n<center><h1>503 Service Temporarily Unavailable</h1></center>\r\n<hr><center>nginx</center>\r\n</body>\r\n</html>"}}
         }}
        |> OpenAI.Client.handle_response()

      assert {:error,
              {:unexpected_token,
               "<html>\r\n<head><title>503 Service Temporarily Unavailable</title></head>\r\n<body>\r\n<center><h1>503 Service Temporarily Unavailable</h1></center>\r\n<hr><center>nginx</center>\r\n</body>\r\n</html>"}} =
               res
    end
  end
end
