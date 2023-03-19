defmodule OpenAi.Finetunes do
  @moduledoc false
  alias OpenAi.Client

  @finetuning_base_url "/v1/fine-tunes"

  def url(), do: @finetuning_base_url
  def url(finetune_id), do: "#{@finetuning_base_url}/#{finetune_id}"
  def cancel_url(finetune_id), do: "#{@finetuning_base_url}/#{finetune_id}/cancel"
  def events_url(finetune_id), do: "#{@finetuning_base_url}/#{finetune_id}/events"

  def fetch(finetune_id) do
    url(finetune_id)
    |> Client.api_get()
  end

  def fetch() do
    url()
    |> Client.api_get()
  end

  def create(params) do
    url()
    |> Client.api_post(params)
  end

  def cancel(finetune_id) do
    cancel_url(finetune_id)
    |> Client.api_post()
  end

  def list_events(finetune_id) do
    events_url(finetune_id)
    |> Client.api_get()
  end
end
