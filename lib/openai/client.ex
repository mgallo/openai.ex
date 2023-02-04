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
      bearer(),
      {"Content-type", "application/json"}
    ]
    |> add_organization_header()
  end

  def bearer(), do: {"Authorization", "Bearer #{Config.api_key()}"}

  def request_options(), do: Config.http_options()

  def api_get(url, request_options \\ []) do
    request_options = Keyword.merge(request_options(), request_options)

    url
    |> get(request_headers(), request_options)
    |> handle_response()
  end

  def api_post(url, params \\ [], request_options \\ []) do
    body =
      params
      |> Enum.into(%{})
      |> JSON.Encoder.encode()
      |> elem(1)

    request_options = Keyword.merge(request_options(), request_options)

    url
    |> post(body, request_headers(), request_options)
    |> handle_response()
  end

  def multipart_api_post(url, file_path, file_param, params, request_options \\ []) do
    body_params = params |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)

    body = {
      :multipart,
      [
        {:file, file_path,
         {"form-data", [{:name, file_param}, {:filename, Path.basename(file_path)}]}, []}
      ] ++ body_params
    }

    request_options = Keyword.merge(request_options(), request_options)

    url
    |> post(body, request_headers(), request_options)
    |> handle_response()
  end

  def api_delete(url, request_options \\ []) do
    request_options = Keyword.merge(request_options(), request_options)

    url
    |> delete(request_headers(), request_options)
    |> handle_response()
  end
end
