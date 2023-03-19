defmodule OpenAi.Moderations do
  @moduledoc false
  alias OpenAi.Client

  @base_url "/v1/moderations"

  def fetch(params) do
    Client.api_post(@base_url, params)
  end
end
