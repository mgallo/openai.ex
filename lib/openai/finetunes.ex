defmodule OpenAI.Finetunes do
  @moduledoc false
  alias OpenAI.Client

  @finetuning_base_url "/v1/fine-tunes"

  def url(), do: @finetuning_base_url
  def url(finetune_id), do: "#{@finetuning_base_url}/#{finetune_id}"

  def fetch(finetune_id, request_options) do
    url(finetune_id)
    |> Client.api_get(request_options)
  end

  def fetch(request_options \\ []) do
    url()
    |> Client.api_get(request_options)
  end
end
