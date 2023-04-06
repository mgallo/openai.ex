defmodule OpenAI.Completions do
  @moduledoc false
  alias OpenAI.Client

  @base_url "/v1/completions"
  @engines_base_url "/v1/engines"

  def deprecated_url(engine_id), do: "#{@engines_base_url}/#{engine_id}/completions"
  def url(), do: @base_url

  def fetch(params, additional_headers: additional_headers) do
    url()
    |> Client.api_post(params, [], additional_headers)
  end

  def fetch(engine_id, params) do
    deprecated_url(engine_id)
    |> Client.api_post(params)
  end

  def fetch(params) do
    url()
    |> Client.api_post(params)
  end
end
