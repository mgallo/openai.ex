defmodule OpenAI.Client do
  @moduledoc false
  alias OpenAI.Config
  use HTTPoison.Base

  def process_url(url), do: Config.api_url() <> url

  def process_response_body(body), do: JSON.decode(body)

  def handle_response(httpoison_response) do
    case httpoison_response do
      {:ok, %HTTPoison.Response{status_code: 200, body: {:ok, body}}} ->
        res =
          body
          |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
          |> Map.new()

        {:ok, res}

      {:ok, %HTTPoison.Response{body: {:ok, body}}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def add_organization_header(headers) do
    if Config.org_key() do
      [{"OpenAI-Organization", Config.org_key()} | headers]
    else
      headers
    end
  end

  def request_headers do
    [
      {"Authorization", "Bearer #{Config.api_key()}"},
      {"Content-type", "application/json"}
    ]
    |> add_organization_header()
  end

  def api_get(url, request_options) do
    url
    |> get(request_headers(), request_options)
    |> handle_response()
  end

  def api_post(url, params, request_options \\ []) do
    body =
      params
      |> Enum.into(%{})
      |> JSON.Encoder.encode()
      |> elem(1)

    url
    |> post(body, request_headers(), request_options)
    |> handle_response()
  end
end
