defmodule OpenAi.Images.Generations do
  @moduledoc false
  alias OpenAi.Client

  @base_url "/v1/images/generations"

  def url(), do: @base_url

  def fetch(params, request_options \\ []) do
    url()
    |> Client.api_post(params, request_options)
  end
end
