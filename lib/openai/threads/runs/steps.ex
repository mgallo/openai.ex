defmodule OpenAI.Threads.Runs.Steps do
  @moduledoc false
  alias OpenAI.Client
  alias OpenAI.Config

  @base_url "/v1/threads"

  def url(thread_id, run_id), do: "#{@base_url}/#{thread_id}/runs/#{run_id}/steps"

  def url(thread_id, run_id, step_id),
    do: "#{@base_url}/#{thread_id}/runs/#{run_id}/steps/#{step_id}"

  def fetch(thread_id, run_id, params \\ [], config \\ %Config{}) do
    url(thread_id, run_id)
    |> Client.api_get(params, config)
  end

  def fetch_by_id(thread_id, run_id, step_id, config \\ %Config{}) do
    url(thread_id, run_id, step_id)
    |> Client.api_get(config)
  end
end
