defmodule OpenAI.Search do
  @moduledoc false
  alias OpenAI.Client

  @base_url "/v1/engines"

  def url(engine_id), do: "#{@base_url}/#{engine_id}/search"

  def fetch(engine_id, params, request_options \\ []) do
    url(engine_id)
    |> Client.api_post(params, request_options)
  end
end
