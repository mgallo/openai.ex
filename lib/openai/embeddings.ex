defmodule OpenAI.Embeddings do
  @moduledoc false
  alias OpenAI.Client

  @embeddings_base_url "/v1/embeddings"

  def url(), do: @embeddings_base_url

  def fetch(params) do
    url()
    |> Client.api_post(params)
  end
end
