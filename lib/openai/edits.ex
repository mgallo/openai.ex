defmodule OpenAI.Edits do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @edits_base_url "/v1/edits"

  def url(), do: @edits_base_url

  def fetch(params, config \\ %Config{}) do
    url()
    |> Client.api_post(params, config)
  end
end
