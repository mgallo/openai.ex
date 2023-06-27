defmodule OpenAI.Finetunes do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @endpoint "/fine-tunes"

  def url(), do: Config.base_url() <> @endpoint
  def url(finetune_id), do: Config.base_url() <> "#{@endpoint}/#{finetune_id}"

  def cancel_url(finetune_id),
    do: Config.base_url() <> "#{@endpoint}/#{finetune_id}/cancel"

  def events_url(finetune_id),
    do: Config.base_url() <> "#{@endpoint}/#{finetune_id}/events"

  def fetch_by_id(finetune_id, config \\ %Config{}) do
    url(finetune_id)
    |> Client.api_get(config)
  end

  def fetch(config \\ %Config{}) do
    url()
    |> Client.api_get(config)
  end

  def create(params, config \\ %Config{}) do
    url()
    |> Client.api_post(params, config)
  end

  def cancel(finetune_id, config \\ %Config{}) do
    cancel_url(finetune_id)
    |> Client.api_post(config)
  end

  def list_events(finetune_id, config \\ %Config{}) do
    events_url(finetune_id)
    |> Client.api_get(config)
  end
end
