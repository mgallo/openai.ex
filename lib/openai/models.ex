defmodule OpenAI.Models do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @endpoint "/models"

  def url(), do: Config.base_url() <> @endpoint
  def url(model_id), do: Config.base_url() <> "#{@endpoint}/#{model_id}"

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
