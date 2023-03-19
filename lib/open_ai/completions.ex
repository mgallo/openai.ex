defmodule OpenAi.Completions do
  @moduledoc false
  alias OpenAi.Client

  @base_url "/v1/completions"
  @engines_base_url "/v1/engines"

  def deprecated_url(engine_id), do: "#{@engines_base_url}/#{engine_id}/completions"
  def fetch(engine_id, params) do
    engine_id
    |> deprecated_url()
    |> Client.api_post(params)
  end

  def fetch(params) do
    Client.api_post(@base_url, params)
  end
end
