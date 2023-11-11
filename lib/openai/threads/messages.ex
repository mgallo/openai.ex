defmodule OpenAI.Threads.Messages do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @base_url "/v1/threads"

  def url(thread_id), do: "#{@base_url}/#{thread_id}/messages"
  def url(thread_id, message_id), do: "#{@base_url}/#{thread_id}/messages/#{message_id}"

  def fetch(thread_id, params \\ [], config \\ %Config{}) do
    url(thread_id)
    |> Client.api_get(params, config)
  end

  def fetch_by_id(thread_id, message_id, config \\ %Config{}) do
    url(thread_id, message_id)
    |> Client.api_get(config)
  end

  def create(thread_id, params, config \\ %Config{}) do
    url(thread_id)
    |> Client.api_post(params, config)
  end

  def update(thread_id, message_id, params, config \\ %Config{}) do
    url(thread_id, message_id)
    |> Client.api_post(params, config)
  end

  def delete(thread_id, message_id, config \\ %Config{}) do
    url(thread_id, message_id)
    |> Client.api_delete(config)
  end
end
