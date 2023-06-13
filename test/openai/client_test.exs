defmodule OpenAI.ClientTest do
  use ExUnit.Case

  @application :openai

  describe "handle_response/1" do
    test "correct responce" do
      res =
        {:ok,
         %HTTPoison.Response{
           body: "correct responce",
           status_code: 200
         }}
        |> OpenAI.Client.handle_response()

      assert {:ok, "correct responce"} = res
    end

    test "httpoison error" do
      res =
        {:error,
         %HTTPoison.Error{
           reason: "bad request"
         }}
        |> OpenAI.Client.handle_response()

      assert {:error, "bad request"} = res
    end

    test "server error" do
      res =
        {:ok, %HTTPoison.Response{
          body: "<html>\r\n<head><title>502 Bad Gateway</title></head>\r\n<body>\r\n<center><h1>502 Bad Gateway</h1></center>\r\n<hr><center>cloudflare</center>\r\n</body>\r\n</html>\r\n",
          status_code: 502
        }}
        |> OpenAI.Client.handle_response()

      assert {:error, 502} = res
    end
  end
end
