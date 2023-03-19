defmodule OpenAi.Client do
  @moduledoc """
  Client module for OpenAi API
  """

  use Tesla
  alias Tesla.Multipart

  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.BaseUrl, "https://api.openai.com"
  plug Tesla.Middleware.BearerAuth, token: Application.get_env(:openai, :api_key)
  plug Tesla.Middleware.Timeout, timeout: Application.get_env(:openai, :http_timeout)

  plug Tesla.Middleware.Headers, [
    {"OpenAI-Organization", Application.get_env(:openai, :organization_key)}
  ]

  def api_get(url, request_options \\ []) do
    get(url, request_options)
  end

  def api_post(url, params \\ [], request_options \\ []) do
    post(url, params, request_options)
  end

  def api_delete(url, request_options \\ []) do
    delete(url, request_options)
  end

  def multipart_api_post(url, file_path, file_param, params, request_options \\ []) do
    multipart =
      Multipart.new()
      |> Multipart.add_file(file_param, file_path)

    post(url, multipart, request_options)
  end
end
