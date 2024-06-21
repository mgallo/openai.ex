defmodule OpenAI.Types.Thread do
  @moduledoc """
  Copied from https://platform.openai.com/docs/api-reference/threads/object

  The thread objectBeta

  Represents a thread of messages between a user and an assistant.

  - id :: string - The identifier, which can be referenced in API endpoints.
  - object :: string - The object type, which is always thread.
  - created_at :: integer - The Unix timestamp (in seconds) for when the thread was created.
  - messages :: list - A list of messages in the thread.
  """
  @type t :: %__MODULE__{
          id: String.t(),
          object: String.t(),
          created_at: integer(),
          tool_resources: map()
        }

  @type tool_resource :: %{
          code_interpreter: code_interpreter(),
          file_search: file_search()
        }

  @type code_interpreter :: %{
          file_ids: [String.t()]
        }

  @type file_search :: %{
          vector_store_ids: [String.t()]
        }

  defstruct id: "",
            object: "",
            created_at: 0,
            tool_resources: %{}
end
