defmodule OpenAI.Finetunes do
  @moduledoc false
  alias OpenAI.Client

  @finetuning_base_url "/v1/fine-tunes"

  def url(), do: @finetuning_base_url
  def url(engine_id), do: "#{@finetuning_base_url}/#{engine_id}"

  def fetch(finetune_id) do
    url(finetune_id)
    |> Client.api_get()
  end

  def fetch() do
    url()
    |> Client.api_get()
  end
end
