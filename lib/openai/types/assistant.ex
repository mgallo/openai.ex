defmodule OpenAI.Types.Assistant do
  @moduledoc """
  Copied from https://platform.openai.com/docs/api-reference/assistants/object

  The assistant objectBeta

  Represents an assistant that can call the model and use tools.

  - id :: string - The identifier, which can be referenced in API endpoints.
  - object :: string - The object type, which is always assistant.
  - created_at :: integer - The Unix timestamp (in seconds) for when the assistant was created.
  - name :: string or null - The name of the assistant. The maximum length is 256 characters.
  - description :: string or null - The description of the assistant. The maximum length is 512 characters.
  - model :: string - ID of the model to use. You can use the List models API to see all of your available models, or see our Model overview for descriptions of them.
  - instructions :: string or null - The system instructions that the assistant uses. The maximum length is 256,000 characters.
  - tools :: list - A list of tool enabled on the assistant. There can be a maximum of 128 tools per assistant. Tools can be of types code_interpreter, file_search, or function.
  - tool_resources :: object or null - A set of resources that are used by the assistant's tools. The resources are specific to the type of tool. For example, the code_interpreter tool requires a list of file IDs, while the file_search tool requires a list of vector store IDs.
  - metadata :: map - Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
  - temperature :: number or null - What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
  - top_p :: number or null - An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
    We generally recommend altering this or temperature but not both.
  - response_format :: string or object - Specifies the format that the model must output. Compatible with GPT-4o, GPT-4 Turbo, and all GPT-3.5 Turbo models since gpt-3.5-turbo-1106.
  """

  @type t :: %__MODULE__{
          id: String.t(),
          object: String.t(),
          created_at: integer(),
          name: String.t() | nil,
          description: String.t() | nil,
          model: String.t(),
          instructions: String.t() | nil,
          tools: [tool()],
          tool_resources: map() | nil,
          metadata: map(),
          temperature: number() | nil,
          top_p: number() | nil,
          response_format: String.t() | map()
        }

  @type tool :: code_interpreter_tool | file_search_tool | function_tool

  @type code_interpreter_tool :: %{
          type: :code_interpreter
        }

  @type file_search_tool :: %{
          type: :file_search,
          file_search: file_search()
        }

  @type file_search :: %{
          max_num_results: integer()
        }

  @type function_tool :: %{
          type: String.t(),
          function: :function
        }

  @type function_tool_function :: %{
          description: String.t(),
          name: String.t(),
          parameters: parameters()
        }

  @type parameters :: %{
          type: String.t(),
          properties: %{required(String.t()) => parameter()},
          required: [String.t()]
        }

  @type parameter :: %{
          type: String.t(),
          description: String.t()
        }

  defstruct id: "",
            object: "assistant",
            created_at: 0,
            name: nil,
            description: nil,
            model: "",
            instructions: nil,
            tools: [],
            tool_resources: nil,
            metadata: %{},
            temperature: nil,
            top_p: nil,
            response_format: %{}
end
