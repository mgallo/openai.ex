defmodule OpenAi.Engines do
  @moduledoc false
  alias OpenAi.Client

  @base_url "/v1/engines"

  def url(engine_id), do: "#{@base_url}/#{engine_id}"

  def fetch, do: Client.api_get(@base_url)

  def fetch(engine_id) do
    engine_id
    |> url()
    |> Client.api_get()
  end
end
