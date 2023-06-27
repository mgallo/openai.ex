defmodule OpenAI.Files do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @endpoint "/files"

  def url(), do: Config.base_url() <> @endpoint
  def url(file_id), do: Config.base_url() <> "#{@endpoint}/#{file_id}"

  def fetch(config \\ %Config{}) do
    url()
    |> Client.api_get(config)
  end

  def fetch_by_id(file_id, config \\ %Config{}) do
    url(file_id)
    |> Client.api_get(config)
  end

  def delete(file_id, config \\ %Config{}) do
    url(file_id)
    |> Client.api_delete(config)
  end

  def upload(file_path, params, config \\ %Config{}) do
    url()
    |> Client.multipart_api_post(file_path, "file", params, config)
  end
end
