defmodule OpenAI.Chat do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @base_url "/v1/chat/completions"

  def url(config) do
    api_type = config.api_type || Config.api_type()

    case api_type do
      :azure -> "/chat/completions"
      _ -> @base_url
    end
  end

  def fetch(params, config \\ %Config{}) do
    url(config)
    |> Client.api_post(params, config)
  end
end
