defmodule OpenAI.VectorStores do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @vector_stores_base_url "/v1/vector_stores"

  def url(), do: @vector_stores_base_url
  def url(vector_store_id), do: "#{@vector_stores_base_url}/#{vector_store_id}"

  def fetch(params, config \\ %Config{}) do
    url()
    |> Client.api_get(params, config)
  end

  def fetch_by_id(vector_store_id, config \\ %Config{}) do
    url(vector_store_id)
    |> Client.api_get(config)
  end

  def create(params, config \\ %Config{}) do
    url()
    |> Client.api_post(params, config)
  end

  def update(vector_store_id, params, config \\ %Config{}) do
    url(vector_store_id)
    |> Client.api_post(params, config)
  end

  def delete(vector_store_id, config \\ %Config{}) do
    url(vector_store_id)
    |> Client.api_delete(config)
  end


end
