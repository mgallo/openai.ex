defmodule OpenAI.Client do
  @moduledoc false
  alias OpenAI.{Config, Stream}
  use HTTPoison.Base

  def process_url(url), do: Config.api_url(url)

  def process_response_body(body) do
    try do
      {status, res} = Jason.decode(body)

      case status do
        :ok ->
          {:ok, res}

        :error ->
          body
      end
    rescue
      _ ->
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

  def add_organization_header(headers, config) do
    org_key = config.organization_key || Config.org_key()

    if org_key do
      [{"OpenAI-Organization", org_key} | headers]
    else
      headers
    end
  end

  def add_custom_headers(headers, config) do
    custom_headers = config.custom_headers || Config.custom_headers()
    headers ++ custom_headers
  end

  def request_headers(config) do
    [
      bearer(config),
      {"Content-type", "application/json"}
    ]
    |> add_organization_header(config)
    |> add_custom_headers(config)
  end

  def bearer(config), do: {"Authorization", "Bearer #{config.api_key || Config.api_key()}"}

  def request_options(config), do: config.http_options || Config.http_options()

  def api_get(url, config) do
    url
    |> get(request_headers(config), request_options(config))
    |> handle_response()
  end

  def api_post(url, params \\ [], config) do
    IO.inspect config, label: "API_POST_CONFIG"

    url = case config.api_url do
      nil ->
        url

      _ ->
        config.api_url <> url
    end

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
