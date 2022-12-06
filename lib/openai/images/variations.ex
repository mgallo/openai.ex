defmodule OpenAI.Images.Edits do
  @moduledoc false
  alias OpenAI.Client

  @base_url "/v1/images/edits"

  def url(), do: @base_url

  def fetch(params, request_options \\ []) do
    url()
    |> Client.api_post(params, request_options)
  end
end