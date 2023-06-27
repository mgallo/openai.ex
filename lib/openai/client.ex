defmodule OpenAI.Client do
  @moduledoc false
  alias OpenAI.{Config, Stream}
  use HTTPoison.Base

  def process_request_url(url) do
    base_url = Config.api_url() <> url

    case Config.api_type() do
      "azure" -> base_url <> "?api-version=#{Config.api_version()}"
      _ -> base_url
    end
  end

  def process_response_body(body) do
    case Jason.decode(body) do
      {:ok, res} ->
        {:ok, res}

      {:error, _res} ->
        body
    end
  end

  def handle_response(httpoison_response) do
    case httpoison_response do
      {:ok, %HTTPoison.Response{status_code: 200, body: {:ok, body}}} ->
        res =
          body
          |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
          |> Map.new()

        {:ok, res}

      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{body: {:ok, body}}} ->
        {:error, body}

      {:ok, %HTTPoison.Response{body: {:error, body}}} ->
        {:error, body}

      # html error responses
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, %{status_code: status_code, body: body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def request_headers(config) do
    [
      {"Content-type", "application/json"}
    ]
    |> add_authorization_header(config)
    |> add_organization_header(config)
  end

  def add_authorization_header(headers, config) do
    token = config.api_key || Config.api_key()

    case Config.api_type() do
      "azure" -> [{"api-key", token} | headers]
      _ -> [{"Authorization", "Bearer #{token}"} | headers]
    end
  end

  def add_organization_header(headers, config) do
    organization_key = config.organization_key || Config.organization_key() || nil

    if organization_key do
      [{"OpenAI-Organization", organization_key} | headers]
    else
      headers
    end
  end

  def request_options(config), do: config.http_options || Config.http_options()

  def api_get(url, config) do
    url
    |> get(request_headers(config), request_options(config))
    |> handle_response()
  end

  def api_post(url, params \\ [], config) do
    body =
      params
      |> Enum.into(%{})
      |> Jason.encode!()

    case params |> Keyword.get(:stream, false) do
      true ->
        Stream.new(fn ->
          url
          |> post(body, request_headers(config), request_options(config))
        end)

      false ->
        url
        |> post(body, request_headers(config), request_options(config))
        |> handle_response()
    end
  end

  def multipart_api_post(url, file_path, file_param, params, config) do
    body_params = params |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)

    body = {
      :multipart,
      [
        {:file, file_path,
         {"form-data", [{:name, file_param}, {:filename, Path.basename(file_path)}]}, []}
      ] ++ body_params
    }

    url
    |> post(body, request_headers(config), request_options(config))
    |> handle_response()
  end

  def api_delete(url, config) do
    url
    |> delete(request_headers(config), request_options(config))
    |> handle_response()
  end
end
