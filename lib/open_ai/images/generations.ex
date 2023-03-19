defmodule OpenAi.Images.Generations do
  @moduledoc false
  alias OpenAi.Client

  @base_url "/v1/images/generations"
  def fetch(params, request_options \\ []) do
    Client.api_post(@base_url, params, request_options)
  end
end
