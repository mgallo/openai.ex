defmodule OpenAI.Config do
  @moduledoc """
  Reads configuration on application start, parses all environment variables (if any)
  and caches the final config in memory to avoid parsing on each read afterwards.
  """

  defstruct api_key: nil,
            organization_key: nil,
            http_options: nil,
            api_url: nil,
            api_type: nil,
            # if api_type is azure, this is required
            azure_deployment_id: nil

  use GenServer

  @openai_url "https://api.openai.com"
  # @allowed_api_types [:openai, :azure]
  @default_api_type :openai

  @config_keys [
    :api_type,
    :api_key,
    :azure_deployment_id,
    :azure_subscription_key,
    :azure_api_version,
    :organization_key,
    :http_options
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

  # API Key
  def api_key, do: get_config_value(:api_key)
  def api_type, do: get_config_value(:api_type, @default_api_type)
  def org_key, do: get_config_value(:organization_key)
  def azure_api_version, do: get_config_value(:azure_api_version)
  def azure_subscription_key, do: get_config_value(:azure_subscription_key)

  # API Url
  def api_url do
    basic_url = get_config_value(:api_url, @openai_url)

    case api_type() do
      :azure -> "#{basic_url}/deployments/#{get_config_value(:azure_deployment_id)}"
      _ -> basic_url
    end
  end

  # HTTP Options
  def http_options, do: get_config_value(:http_options, [])

  defp get_config_value(key, default \\ nil) do
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

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl true
  def handle_call({:put, key, value}, _from, state) do
    {:reply, value, Map.put(state, key, value)}
  end
end
