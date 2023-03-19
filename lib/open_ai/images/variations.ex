defmodule OpenAi.Images.Variations do
  @moduledoc false
  alias OpenAi.Client

  @base_url "/v1/images/variations"

  def url(), do: @base_url

  def fetch(file_path, params \\ [], request_options \\ []) do
    url()
    |> Client.multipart_api_post(file_path, "image", params, request_options)
  end
end
