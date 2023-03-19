defmodule OpenAi.Finetunes do
  @moduledoc false
  alias OpenAi.Client

  @base_url "/v1/fine-tunes"

  def url(finetune_id), do: "#{@base_url}/#{finetune_id}"
  def cancel_url(finetune_id), do: "#{@base_url}/#{finetune_id}/cancel"
  def events_url(finetune_id), do: "#{@base_url}/#{finetune_id}/events"

  def fetch, do: Client.api_get(@base_url)

  def fetch(finetune_id) do
    finetune_id
    |> url()
    |> Client.api_get()
  end

  def create(params) do
    Client.api_post(@base_url, params)
  end

  def cancel(finetune_id) do
    finetune_id
    |> cancel_url()
    |> Client.api_post()
  end

  def list_events(finetune_id) do
    finetune_id
    |> events_url()
    |> Client.api_get()
  end
end
