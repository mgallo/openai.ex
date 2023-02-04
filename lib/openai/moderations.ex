defmodule OpenAI.Moderations do
  @moduledoc false
  alias OpenAI.Client

  @moderations_base_url "/v1/moderations"

  def url(), do: @moderations_base_url

  def fetch(params) do
    url()
    |> Client.api_post(params)
  end
end
