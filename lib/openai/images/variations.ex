defmodule OpenAI.Images.Variations do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @base_url "/v1/images/variations"

  def url(), do: @base_url

  def fetch(file_path, params \\ [], config \\ %Config{}) do
    url()
    |> Client.multipart_api_post(file_path, "image", params, config)
  end

  def fetch_legacy(file_path, params \\ [], request_options) do
    config = %Config{http_options: request_options}

    url()
    |> Client.multipart_api_post(file_path, "image", params, config)
  end
end
