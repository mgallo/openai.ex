defmodule OpenAi.Embeddings do
  @moduledoc false
  alias OpenAi.Client

  @embeddings_base_url "/v1/embeddings"

  def url(), do: @embeddings_base_url

  def fetch(params) do
    url()
    |> Client.api_post(params)
  end
end
