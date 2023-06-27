defmodule OpenAI.Completions do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @endpoint "/completions"
  @engines_base_url "/engines"

  def url(), do: Config.base_url() <> @endpoint

  def deprecated_url(engine_id),
    do: Config.base_url() <> "#{@engines_base_url}/#{engine_id}/completions"

  def fetch(params, config \\ %Config{}) do
    url()
    |> Client.api_post(params, config)
  end

  def fetch_by_engine(engine_id, params, config \\ %Config{}) do
    deprecated_url(engine_id)
    |> Client.api_post(params, config)
  end
end
