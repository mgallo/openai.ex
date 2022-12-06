defmodule OpenAI.Engines do
  @moduledoc false
  alias OpenAI.Client

  @engines_base_url "/v1/engines"

  def url(), do: @engines_base_url
  def url(engine_id), do: "#{@engines_base_url}/#{engine_id}"

  def fetch(engine_id, request_options) do
    url(engine_id)
    |> Client.api_get(request_options)
  end

  def fetch(request_options \\ []) do
    url()
    |> Client.api_get(request_options)
  end
end
