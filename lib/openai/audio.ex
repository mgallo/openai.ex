defmodule OpenAI.Audio do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @endpoint "/audio"
  def transcriptions_url(), do: Config.base_url() <> "#{@endpoint}/transcriptions"
  def translations_url(), do: Config.base_url() <> "#{@endpoint}/translations"

  def transcription(file_path, params, config \\ %Config{}) do
    transcriptions_url()
    |> Client.multipart_api_post(file_path, "file", params, config)
  end

  def translation(file_path, params, config \\ %Config{}) do
    translations_url()
    |> Client.multipart_api_post(file_path, "file", params, config)
  end
end
