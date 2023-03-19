defmodule OpenAi.Embeddings do
  @moduledoc false
  alias OpenAi.Client

  @base_url "/v1/embeddings"

  def fetch(params) do
    Client.api_post(@base_url, params)
  end
end
