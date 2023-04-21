defmodule OpenAI.Images.Edits do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @base_url "/v1/images/edits"

  def url(), do: @base_url

  def fetch(file_path, params, config \\ %Config{}) do
    url()
    |> Client.multipart_api_post(file_path, "image", params, config)
  end
end
