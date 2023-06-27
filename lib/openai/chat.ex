defmodule OpenAI.Chat do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @endpoint "/chat/completions"

  def url(), do: Config.base_url() <> @endpoint

  def fetch(params, config \\ %Config{}) do
    url() |> Client.api_post(params, config)
  end
end
