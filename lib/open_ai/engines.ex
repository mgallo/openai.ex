defmodule OpenAi.Engines do
  @moduledoc false
  alias OpenAi.Client

  @engines_base_url "/v1/engines"

  def url(), do: @engines_base_url
  def url(engine_id), do: "#{@engines_base_url}/#{engine_id}"

  def fetch(engine_id) do
    url(engine_id)
    |> Client.api_get()
  end

  def fetch() do
    url()
    |> Client.api_get()
  end
end
