defmodule OpenAi.Completions do
  @moduledoc false
  alias OpenAi.Client

  @base_url "/v1/completions"
  @engines_base_url "/v1/engines"

  def deprecated_url(engine_id), do: "#{@engines_base_url}/#{engine_id}/completions"
  def url(), do: @base_url

  def fetch(engine_id, params) do
    deprecated_url(engine_id)
    |> Client.api_post(params)
  end

  def fetch(params) do
    url()
    |> Client.api_post(params)
  end
end
