defmodule OpenAi.Search do
  @moduledoc false
  alias OpenAi.Client

  @base_url "/v1/engines"

  def engine_url(engine_id), do: "#{@base_url}/#{engine_id}/search"

  def fetch(engine_id, params) do
    engine_id
    |> engine_url()
    |> Client.api_post(params)
  end
end
