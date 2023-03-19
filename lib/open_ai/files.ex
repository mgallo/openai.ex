defmodule OpenAi.Files do
  @moduledoc false
  alias OpenAi.Client

  @files_base_url "/v1/files"

  def url(), do: @files_base_url
  def url(file_id), do: "#{@files_base_url}/#{file_id}"

  def fetch() do
    url()
    |> Client.api_get()
  end

  def fetch(file_id) do
    url(file_id)
    |> Client.api_get()
  end

  def delete(file_id) do
    url(file_id)
    |> Client.api_delete()
  end

  def upload(file_path, params) do
    url()
    |> Client.multipart_api_post(file_path, "file", params)
  end
end
