defmodule OpenAI.Models do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @models_base_url "/v1/models"

  def url(), do: @models_base_url
  def url(model_id), do: "#{@models_base_url}/#{model_id}"

  def fetch_by_id(model_id, config \\ %Config{}) do
    url(model_id)
    |> Client.api_get(config)
  end

  def fetch(config \\ %Config{}) do
    url()
    |> Client.api_get(config)
  end

  def delete(model_id, config \\ %Config{}) do
    url(model_id)
    |> Client.api_delete(config)
  end
end
