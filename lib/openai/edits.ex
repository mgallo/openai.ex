defmodule OpenAI.Edits do
  @moduledoc false
  alias OpenAI.Client

  @edits_base_url "/v1/edits"

  def url(), do: @edits_base_url

  def fetch(params) do
    url()
    |> Client.api_post(params)
  end
end
