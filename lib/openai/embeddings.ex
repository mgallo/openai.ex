defmodule OpenAI.Embeddings do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @endpoint "/embeddings"

  def url(), do: Config.base_url() <> @endpoint

  def fetch(params, config \\ %Config{}) do
    url()
    |> Client.api_post(params, config)
  end
end
