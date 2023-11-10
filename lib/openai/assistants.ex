defmodule OpenAI.Assistants do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @base_url "/v1/assistants"

  def assistants_url(), do: @base_url
  def assistants_url(assistant_id), do: "#{@base_url}/#{assistant_id}"
  def assistant_files_url(assistant_id), do: "#{@base_url}/#{assistant_id}/files"

  def fetch(params, config \\ %Config{}) do
    assistants_url()
    |> Client.api_get(params, config)
  end

  def fetch_by_id(assistant_id, config \\ %Config{}) do
    assistants_url(assistant_id)
    |> Client.api_get(config)
  end

  def fetch_files(assistant_id, params \\ [], config \\ %Config{}) do
    assistant_files_url(assistant_id)
    |> Client.api_get(params, config)
  end
end
