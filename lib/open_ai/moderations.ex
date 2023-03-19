defmodule OpenAi.Moderations do
  @moduledoc false
  alias OpenAi.Client

  @moderations_base_url "/v1/moderations"

  def url(), do: @moderations_base_url

  def fetch(params) do
    url()
    |> Client.api_post(params)
  end
end
