defmodule OpenAi.Files do
  @moduledoc false
  alias OpenAi.Client

  @base_url "/v1/files"

  def url(file_id), do: "#{@base_url}/#{file_id}"

  def fetch, do: Client.api_get(@base_url)

  def fetch(file_id) do
    file_id
    |> url()
    |> Client.api_get()
  end

  def delete(file_id) do
    file_id
    |> url()
    |> Client.api_delete()
  end

  def upload(file_path, params) do
    Client.multipart_api_post(@base_url, file_path, "file", params)
  end
end
