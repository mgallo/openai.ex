defmodule OpenAI.Models do
  @moduledoc false
  alias OpenAI.Client

  @models_base_url "/v1/models"

  def url(), do: @models_base_url
  def url(model_id), do: "#{@models_base_url}/#{model_id}"

  def fetch(model_id) do
    url(model_id)
    |> Client.api_get()
  end

  def fetch() do
    url()
    |> Client.api_get()
  end

  def delete(model_id) do
    url(model_id)
    |> Client.api_delete()
  end
end
