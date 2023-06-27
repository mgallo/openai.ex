defmodule OpenAI.Engines do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @endpoint "/engines"

  def url(), do: Config.base_url() <> @endpoint
  def url(engine_id), do: Config.base_url() <> "#{@endpoint}/#{engine_id}"

  def fetch_by_id(engine_id, config \\ %Config{}) do
    url(engine_id)
    |> Client.api_get(config)
  end

  def fetch(config \\ %Config{}) do
    url()
    |> Client.api_get(config)
  end
end
