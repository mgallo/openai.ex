defmodule OpenAI.Client do
  @moduledoc false

  alias OpenAI.{Config, Stream}
  use HTTPoison.Base

  def process_url(url), do: Config.api_url() <> url

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

  def request_headers(config) do
    [
      bearer(config),
      {"Content-type", "application/json"}
    ]
    |> List.flatten()
    |> add_organization_header(config)
  end

  def bearer(config) do
    case Config.api_type() do
      :azure ->
        [
          {"api-key", Config.api_key()},
          {"subscription-key", Config.azure_subscription_key()}
        ]

      _ ->
        {"Authorization", "Bearer #{config.api_key || Config.api_key()}"}
    end
  end

  def request_options(config), do: config.http_options || Config.http_options()

  def api_get(url, config) do
    url
    |> add_params_to_url()
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
          |> add_params_to_url()
          |> post(body, request_headers(config), request_options(config))
        end)

      false ->
        url
        |> add_params_to_url()
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

  defp add_params_to_url(url) do
    case Config.api_type() do
      :azure ->
        azure_params = %{"api-version" => Config.azure_api_version()}

        url
        |> URI.parse()
        |> merge_uri_params(azure_params)
        |> URI.to_string()

      _ ->
        url
    end
  end

  defp merge_uri_params(uri, []), do: uri

  defp merge_uri_params(%URI{query: nil} = uri, params) when is_list(params) or is_map(params) do
    uri
    |> Map.put(:query, URI.encode_query(params))
  end

  defp merge_uri_params(%URI{} = uri, params) when is_list(params) or is_map(params) do
    uri
    |> Map.update!(:query, fn q ->
      q
      |> URI.decode_query()
      |> Map.merge(param_list_to_map_with_string_keys(params))
      |> URI.encode_query()
    end)
  end

  defp param_list_to_map_with_string_keys(list) when is_list(list) or is_map(list) do
    for {key, value} <- list, into: Map.new() do
      {"#{key}", value}
    end
  end
end
