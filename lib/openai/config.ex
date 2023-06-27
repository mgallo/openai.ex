defmodule OpenAI.Config do
  @moduledoc """
  Reads configuration on application start, parses all environment variables (if any)
  and caches the final config in memory to avoid parsing on each read afterwards.
  """

  defstruct api_key: nil,
            organization_key: nil,
            http_options: nil,
            api_url: nil,
            api_deployment_name: nil,
            api_type: nil,
            api_version: nil

  use GenServer

  @openai_url "https://api.openai.com"
  @openai_endpoint_version "/v1"

  @config_keys [
    :api_key,
    :organization_key,
    :http_options,
    :api_deployment_name,
    :api_type,
    :api_version
  ]

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(_opts) do
    config =
      @config_keys
      |> Enum.map(fn key -> {key, get_config_value(key)} end)
      |> Map.new()

    {:ok, config}
  end

  def base_url, do: api_deployment_name() || @openai_endpoint_version

  # API Key
  def api_key, do: get_config_value(:api_key)
  def organization_key, do: get_config_value(:organization_key)
  def api_type, do: get_config_value(:api_type)
  def api_version, do: get_config_value(:api_version)
  def api_deployment_name, do: get_config_value(:api_deployment_name)
  def api_url, do: get_config_value(:api_url)
  def http_options, do: get_config_value(:http_options)

  defp get_config_value(:http_options), do: get_local_env(:http_options, [])
  defp get_config_value(:api_url), do: get_local_env(:api_url, @openai_url)
  defp get_config_value(:api_version), do: get_local_env(:api_version)
  defp get_config_value(:organization_key), do: get_local_env(:organization_key)
  defp get_config_value(:api_key), do: get_local_env(:api_key)
  defp get_config_value(:api_type), do: get_local_env(:api_type)

  defp get_config_value(:api_deployment_name) do
    api_deployment_name = get_local_env(:api_deployment_name)

    if api_deployment_name != nil do
      "/openai/deployments/#{api_deployment_name}"
    end
  end

  def get_local_env(key), do: get_local_env(key, nil)

  def get_local_env(key, default) do
    value =
      :openai
      |> Application.get_env(key)
      |> parse_config_value()

    if is_nil(value), do: default, else: value
  end

  defp parse_config_value({:system, env_name}), do: fetch_env!(env_name)

  defp parse_config_value({:system, :integer, env_name}) do
    env_name
    |> fetch_env!()
    |> String.to_integer()
  end

  defp parse_config_value(value), do: value

  # System.fetch_env!/1 support for older versions of Elixir
  defp fetch_env!(env_name) do
    case System.get_env(env_name) do
      nil ->
        raise ArgumentError,
          message: "could not fetch environment variable \"#{env_name}\" because it is not set"

      value ->
        value
    end
  end

  def get(key), do: GenServer.call(__MODULE__, {:get, key})

  def put(key, value), do: GenServer.call(__MODULE__, {:put, key, value})

  def list(), do: GenServer.call(__MODULE__, {:list})

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl true
  def handle_call({:put, key, value}, _from, state) do
    {:reply, value, Map.put(state, key, value)}
  end

  @impl true
  def handle_call({:list}, _from, state) do
    {:reply, state, state}
  end
end
