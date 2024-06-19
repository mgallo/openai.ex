defmodule OpenAI.Assistants.Assistants do
  @moduledoc """
  Build assistants that can call models and use tools to perform tasks.
  (Get started with the Assistants API)[https://platform.openai.com/docs/assistants/overview]

  https://platform.openai.com/docs/api-reference/assistants
  """

  alias OpenAI.Client
  alias OpenAI.Config
  alias OpenAI.Types

  @base_url "/v1/assistants"

  defmodule CreateRequest do
    @moduledoc false

    @type t :: %{
            model: String.t(),
            name: String.t(),
            description: String.t(),
            instructions: String.t(),
            tools: [String.t()],
            tool_resources: map(),
            metadata: map(),
            temperature: number(),
            top_p: number(),
            response_format: String.t() | map()
          }
    defstruct model: "",
              name: "",
              description: "",
              instructions: "",
              tools: [],
              tool_resources: %{},
              metadata: %{},
              temperature: 0.0,
              top_p: 0.0,
              response_format: %{}
  end

  @spec create(__MODULE__.CreateRequest.t()) :: {:ok, Types.Assistant.t()} | {:error, String.t()}
  def create(params, config \\ %Config{}) do
    @base_url
    |> Client.api_post(params |> Map.to_list(), config)
    |> case do
      {:ok, res} when res |> is_map -> {:ok, struct(Types.Assistant, res)}
      {:ok, res} -> {:error, res}
      {:error, res} -> {:error, res}
    end
  end
end
