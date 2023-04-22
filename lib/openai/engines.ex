defmodule OpenAI.Engines do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @engines_base_url "/v1/engines"

  def url(), do: @engines_base_url
  def url(engine_id), do: "#{@engines_base_url}/#{engine_id}"

  def fetch_by_id(engine_id, config \\ %Config{}) do
    url(engine_id)
    |> Client.api_get(config)
  end

  def fetch(config \\ %Config{}) do
    url()
    |> Client.api_get(config)
  end
end
