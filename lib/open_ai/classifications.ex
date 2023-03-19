defmodule OpenAi.Classifications do
  @moduledoc false
  alias OpenAi.Client

  @base_url "/v1/classifications"

  def url(), do: @base_url

  def fetch(params) do
    url()
    |> Client.api_post(params)
  end
end
