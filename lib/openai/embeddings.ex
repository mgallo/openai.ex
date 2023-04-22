defmodule OpenAI.Embeddings do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @embeddings_base_url "/v1/embeddings"

  def url(), do: @embeddings_base_url

  def fetch(params, config \\ %Config{}) do
    url()
    |> Client.api_post(params, config)
  end
end
