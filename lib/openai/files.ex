defmodule OpenAI.Files do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @files_base_url "/v1/files"

  def url(), do: @files_base_url
  def url(file_id), do: "#{@files_base_url}/#{file_id}"

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

  def upload(file_path, params, config \\ %Config{})

  def upload(file_path, params, config) when is_binary(file_path) do
    url()
    |> Client.multipart_api_post(file_path, "file", params, config)
  end

  def upload(%{path: file_path, filename: file_name}, params, config) do
    url()
    |> Client.multipart_api_post(file_path, "file", file_name, params, config)
  end
end
