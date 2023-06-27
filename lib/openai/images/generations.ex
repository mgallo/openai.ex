defmodule OpenAI.Images.Generations do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @endpoint "/images/generations"

  def url(), do: Config.base_url() <> @endpoint

  def fetch(params, config \\ %Config{}) do
    url()
    |> Client.api_post(params, config)
  end

  def fetch_legacy(params, request_options) do
    config = %Config{http_options: request_options}

    url()
    |> Client.api_post(params, config)
  end
end
