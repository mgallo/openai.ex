defmodule OpenAi.Models do
  @moduledoc false
  alias OpenAi.Client

  @base "/v1/models"
  def url(model_id), do: "#{@base}/#{model_id}"

  def fetch(model_id) do
    model_id
    |> url()
    |> Client.api_get()
  end

  def fetch() do
    Client.api_get(@base)
  end

  def delete(model_id) do
    model_id
    |> url()
    |> Client.api_delete()
  end
end
