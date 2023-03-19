defmodule OpenAi.Models do
  @moduledoc false
  alias OpenAi.Client

  @base "/v1/models"
  def url(model_id), do: "#{@base}/#{model_id}"
  def fetch, do: Client.api_get(@base)

  def fetch(model_id) do
    model_id
    |> url()
    |> Client.api_get()
  end

  def delete(model_id) do
    model_id
    |> url()
    |> Client.api_delete()
  end
end
