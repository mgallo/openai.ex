defmodule OpenAI.Classifications do
  @moduledoc false
  alias OpenAI.Client

  @base_url "/v1/classifications"

  def url(), do: @base_url

  def fetch(params) do
    url()
    |> Client.api_post(params)
  end
end
