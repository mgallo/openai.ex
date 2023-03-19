defmodule OpenAi.Images.Variations do
  @moduledoc false
  alias OpenAi.Client

  @base_url "/v1/images/variations"

  def fetch(file_path, params \\ [], request_options \\ []) do
    Client.multipart_api_post(@base_url, file_path, "image", params, request_options)
  end
end
