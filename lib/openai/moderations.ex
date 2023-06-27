defmodule OpenAI.Moderations do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @endpoint "/moderations"

  def url(), do: Config.base_url() <> @endpoint

  def fetch(params, config \\ %Config{}) do
    url()
    |> Client.api_post(params, config)
  end
end
