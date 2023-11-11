defmodule OpenAI.Threads do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @base_url "/v1/threads"

  def url(), do: @base_url
  def url(thread_id), do: "#{@base_url}/#{thread_id}"

  def fetch_by_id(thread_id, config \\ %Config{}) do
    url(thread_id)
    |> Client.api_get(config)
  end

  def create(params, config \\ %Config{}) do
    url()
    |> Client.api_post(params, config)
  end

  def update(thread_id, params, config \\ %Config{}) do
    url(thread_id)
    |> Client.api_post(params, config)
  end

  def delete(thread_id, config \\ %Config{}) do
    url(thread_id)
    |> Client.api_delete(config)
  end
end
