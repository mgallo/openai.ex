defmodule OpenAI do
  @moduledoc """
  Provides API wrappers for OpenAI API
  See https://beta.openai.com/docs/api-reference/introduction for further info on REST endpoints
  """

  use Application

  alias OpenAI.Config
  alias OpenAI.Completions
  alias OpenAI.Finetunes
  alias OpenAI.Images
  alias OpenAI.Files
  alias OpenAI.Models
  alias OpenAI.Edits
  alias OpenAI.Embeddings
  alias OpenAI.Moderations
  alias OpenAI.Chat
  alias OpenAI.Audio
  alias OpenAI.Engines
  alias OpenAI.Assistants
  alias OpenAI.Threads

  def start(_type, _args) do
    children = [Config]
    opts = [strategy: :one_for_one, name: OpenAI.Supervisor]

    Supervisor.start_link(children, opts)
  end

  @doc """
  Retrieve the list of available models
  ## Example request
      OpenAI.models()

  ## Example response
       %{
       "created" => 1651172505,
       "id" => "davinci-search-query",
       "object" => "model",
       "owned_by" => "openai-dev",
       "parent" => nil,
       "permission" => [
         %{
           "allow_create_engine" => false,
           "allow_fine_tuning" => false,
           "allow_logprobs" => true,
           ...
         }
       ],
       "root" => "davinci-search-query"
     }
  See: https://platform.openai.com/docs/api-reference/models/retrieve

  Retrieve specific model info
  ## Example request
      OpenAI.models("davinci-search-query")

  ## Example response
       {:ok, %{
  data: [%{
    "created" => 1651172505,
    "id" => "davinci-search-query",
    "object" => "model",
    "owned_by" => "openai-dev",
    "parent" => nil,
    "permission" => [
      %{
        "allow_create_engine" => false,
        "allow_fine_tuning" => false,
        "allow_logprobs" => true,
        ...
      }
    ],
    "root" => "davinci-search-query"
  },
  ....],
  object: "list"
  }}
  See: https://platform.openai.com/docs/api-reference/models/retrieve
  """
  def models(config) when is_struct(config), do: Models.fetch(config)
  def models(model_id) when is_bitstring(model_id), do: Models.fetch_by_id(model_id)
  def models(), do: Models.fetch()
  def models(model_id, config), do: Models.fetch_by_id(model_id, config)

  # def static_translate(key, opts \\ []) do
  # end

  # def static_translate(module, key, opts \\ []) do
  # end

  @doc """
  Retrieves the list of assistants.

  ## Example request
  ```elixir
      OpenAI.assistants()
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        data: [
          %{
            "created_at" => 1699472932,
            "description" => nil,
            "file_ids" => ["file-..."],
            "id" => "asst_...",
            "instructions" => "...",
            "metadata" => %{},
            "model" => "gpt-4-1106-preview",
            "name" => "...",
            "object" => "assistant",
            "tools" => [%{"type" => "retrieval"}]
          }
        ],
        first_id: "asst_...",
        has_more: false,
        last_id: "asst_...",
        object: "list"
      }}
  ```

  Retrieves the list of assistants filtered by query params.

  ## Example request
  ```elixir
      OpenAI.assistants(after: "", limit: 10)
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        data: [
          %{
            "created_at" => 1699472932,
            "description" => nil,
            "file_ids" => ["file-..."],
            "id" => "asst_...",
            "instructions" => "...",
            "metadata" => %{},
            "model" => "gpt-4-1106-preview",
            "name" => "...",
            "object" => "assistant",
            "tools" => [%{"type" => "retrieval"}]
          },
          ...
        ],
        first_id: "asst_...",
        has_more: false,
        last_id: "asst_...",
        object: "list"
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/assistants/listAssistants

  Retrieves an assistant by its id.

  ## Example request
  ```elixir
      OpenAI.assistants("asst_...")
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        created_at: 1699472932,
        description: nil,
        file_ids: ["file-..."],
        id: "asst_...",
        instructions: "...",
        metadata: %{},
        model: "gpt-4-1106-preview",
        name: "...",
        object: "assistant",
        tools: [%{"type" => "retrieval"}]
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/assistants/getAssistant
  """
  def assistants(params \\ [], config \\ %Config{})

  def assistants(params, config) when is_list(params) and is_struct(config),
    do: Assistants.fetch(params, config)

  def assistants(assistant_id, config) when is_bitstring(assistant_id) and is_struct(config),
    do: Assistants.fetch_by_id(assistant_id, config)

  @doc"""
  Creates a new assistant.

  ## Example request
  ```elixir
      OpenAI.assistants_create(
        model: "gpt-3.5-turbo-1106",
        name: "My assistant",
        instructions: "You are a research assistant.",
        tools: [
          %{type: "retrieval"}
        ],
        file_ids: ["file-..."]
      )
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        created_at: 1699640038,
        description: nil,
        file_ids: ["file-..."],
        id: "asst_...",
        instructions: "You are a research assistant.",
        metadata: %{},
        model: "gpt-3.5-turbo-1106",
        name: "My assistant",
        object: "assistant",
        tools: [%{"type" => "retrieval"}]
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/assistants/createAssistant
  """
  def assistants_create(params, config \\ %Config{})
    when is_list(params) and is_struct(config)
  do
    Assistants.create(params, config)
  end

  @doc """
  Modifies an existing assistant.

  ## Example request
  ```elixir
      OpenAI.assistants_modify(
        "asst_...",
        model: "gpt-4-1106-preview",
        name: "My upgraded assistant"
      )
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        created_at: 1699640038,
        description: nil,
        file_ids: ["file-..."],
        id: "asst_...",
        instructions: "You are a research assistant.",
        metadata: %{},
        model: "gpt-4-1106-preview",
        name: "My upgraded assistant"
        object: "assistant",
        tools: [%{"type" => "retrieval"}]
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/assistants/modifyAssistant
  """
  def assistants_modify(assistant_id, params, config \\ %Config{})
    when is_bitstring(assistant_id) and is_list(params) and is_struct(config)
  do
    Assistants.update(assistant_id, params, config)
  end

  @doc """
  Deletes an assistant.

  ## Example request
  ```elixir
     OpenAI.assistants_delete("asst_...")
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        deleted: true,
        id: "asst_...",
        object: "assistant.deleted"
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/assistants/deleteAssistant
  """
  def assistants_delete(assistant_id, config \\ %Config{})
    when is_bitstring(assistant_id) and is_struct(config)
  do
    Assistants.delete(assistant_id, config)
  end

  @doc """
  Retrieves the list of files associated with a particular assistant.

  ## Example request
  ```elixir
      OpenAI.assistant_files("asst_...")
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        data: [
          %{
            "assistant_id" => "asst_...",
            "created_at" => 1699472933,
            "id" => "file-...",
            "object" => "assistant.file"
          }
        ],
        first_id: "file-...",
        has_more: false,
        last_id: "file-...",
        object: "list"
      }}
  ```

  Retrieves the list of files associated with a particular assistant, filtered
  by query params.

  ## Example request
  ```elixir
      OpenAI.assistant_files("asst_...", order: "desc")
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        data: [
          %{
            "assistant_id" => "asst_...",
            "created_at" => 1699472933,
            "id" => "file-...",
            "object" => "assistant.file"
          }
        ],
        first_id: "file-...",
        has_more: false,
        last_id: "file-...",
        object: "list"
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/assistants/listAssistantFiles
  """
  def assistant_files(assistant_id, params \\ [], config \\ %Config{})
    when is_bitstring(assistant_id) and is_list(params) and is_struct(config)
  do
    Assistants.Files.fetch(assistant_id, params, config)
  end

  @doc """
  Retrieves an assistant file by its id.

  ## Example request
  ```elixir
      OpenAI.assistant_file("asst_...", "file-...")
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        assistant_id: "asst_...",
        created_at: 1699472933,
        id: "file-...",
        object: "assistant.file"
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/assistants/getAssistantFile
  """
  def assistant_file(assistant_id, file_id, config \\ %Config{})
    when is_bitstring(assistant_id) and is_bitstring(file_id) and is_struct(config)
  do
    Assistants.Files.fetch_by_id(assistant_id, file_id, config)
  end

  @doc """
  Attaches a previously uploaded file to the assistant.

  ## Example request
  ```elixir
      OpenAI.assistant_file_create("asst_...", file_id: "file-...")
  ```

  ## Example response
  ```elixir
    {:ok,
    %{
      assistant_id: "asst_...",
      created_at: 1699472933,
      id: "file-...",
      object: "assistant.file"
    }}
  ```

  See: https://platform.openai.com/docs/api-reference/assistants/getAssistantFile
  """
  def assistant_file_create(assistant_id, params, config \\ %Config{})
    when is_bitstring(assistant_id) and is_list(params) and is_struct(config)
  do
    Assistants.Files.create(assistant_id, params, config)
  end

  @doc """
  Detaches a file from the assistant. The file itself is not automatically deleted.

  ## Example request
  ```elixir
      OpenAI.assistant_file_delete("asst_...", "file-...")
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        deleted: true,
        id: "file-...",
        object: "assistant.file.deleted"
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/assistants/getAssistantFile
  """
  def assistant_file_delete(assistant_id, file_id, config \\ %Config{})
    when is_bitstring(assistant_id) and is_bitstring(file_id) and is_struct(config)
  do
    Assistants.Files.delete(assistant_id, file_id, config)
  end

  @doc """
  Retrieves the list of threads.

  **NOTE:** At the time of this writing this functionality remains undocumented by OpenAI.

  ## Example request
  ```elixir
      OpenAI.threads()
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        data: [
          %{
            "created_at" => 1699705727,
            "id" => "thread_...",
            "metadata" => %{"key_1" => "value 1", "key_2" => "value 2"},
            "object" => "thread"
          },
          ...
        ],
        first_id: "thread_...",
        has_more: false,
        last_id: "thread_...",
        object: "list"
      }}
  ```

  Retrieves a filtered list of threads.

  **NOTE:** At the time of this writing this functionality remains undocumented by OpenAI.

  ## Example request
  ```elixir
      OpenAI.threads(limit: 2)
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        data: [
          %{
            "created_at" => 1699705727,
            "id" => "thread_...",
            "metadata" => %{"key_1" => "value 1", "key_2" => "value 2"},
            "object" => "thread"
          },
          %{
            "created_at" => 1699704406,
            "id" => "thread_...",
            "metadata" => %{"key_1" => "value 1", "key_2" => "value 2", "key_3" => "value 3"},
            "object" => "thread"
          }
        ],
        first_id: "thread_...",
        has_more: true,
        last_id: "thread_...",
        object: "list"
      }}
  ```

  Retrieves a thread by its id.

  ## Example request
  ```elixir
      OpenAI.threads("thread_..."")
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        created_at: 1699703890,
        id: "thread_...",
        metadata: %{"key_1" => "value 1", "key_2" => "value 2"},
        object: "thread"
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/threads/getThread
  """
  def threads(params \\ [], config \\ %Config{})

  def threads(params, config) when is_list(params) and is_struct(config),
    do: Threads.fetch(params, config)

  def threads(thread_id, config) when is_bitstring(thread_id) and is_struct(config),
    do: Threads.fetch_by_id(thread_id, config)

  @doc """
  Creates a new thread.

  ## Example request
  ```elixir
      OpenAI.threads_create()
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        created_at: 1699703548,
        id: "thread_...",
        metadata: %{},
        object: "thread"
      }}
  ```

  Creates a new thread with some messages and metadata.

  ## Example request
  ```elixir
      messages = [
        %{
          role: "user",
          content: "Hello, what is AI?",
          file_ids: ["file-..."]
        },
        %{
          role: "user",
          content: "How does AI work? Explain it in simple terms."
        },
      ]

      metadata = %{
        key_1: "value 1",
        key_2: "value 2"
      }

      OpenAI.threads_create(messages: messages, metadata: metadata)
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        created_at: 1699703890,
        id: "thread_...",
        metadata: %{"key_1" => "value 1", "key_2" => "value 2"},
        object: "thread"
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/threads/createThread
  """
  def threads_create(params \\ [], config \\ %Config{})
    when is_list(params) and is_struct(config)
  do
    Threads.create(params, config)
  end

  @doc """
  Creates a new thread and runs it.

  ## Example request
  ```elixir
      messages = [
        %{
          role: "user",
          content: "Hello, what is AI?",
          file_ids: ["file-..."]
        },
        %{
          role: "user",
          content: "How does AI work? Explain it in simple terms."
        },
      ]

      thread_metadata = %{
        key_1: "value 1",
        key_2: "value 2"
      }

      thread = %{
        messages: messages,
        metadata: thread_metadata
      }

      run_metadata = %{
        key_3: "value 3"
      }

      params = [
        assistant_id: "asst_...",
        thread: thread,
        model: "gpt-4-1106-preview",
        instructions: "You are an AI learning assistant.",
        tools: [%{
          "type" => "retrieval"
        }],
        metadata: run_metadata
      ]

      OpenAI.threads_create_and_run(params)
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        assistant_id: "asst_...",
        cancelled_at: nil,
        completed_at: nil,
        created_at: 1699897907,
        expires_at: 1699898507,
        failed_at: nil,
        file_ids: ["file-..."],
        id: "run_...",
        instructions: "You are an AI learning assistant.",
        last_error: nil,
        metadata: %{"key_3" => "value 3"},
        model: "gpt-4-1106-preview",
        object: "thread.run",
        started_at: nil,
        status: "queued",
        thread_id: "thread_...",
        tools: [%{"type" => "retrieval"}]
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/runs/createThreadAndRun
  """
  def threads_create_and_run(params \\ [], config \\ %Config{})
    when is_list(params) and is_struct(config)
  do
    Threads.create_and_run(params, config)
  end
  @doc """
  Modifies an existing thread.

  ## Example request
  ```elixir
      metadata = %{
        key_3: "value 3"
      }

      OpenAI.threads_modify("thread_...", metadata: metadata)
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        created_at: 1699704406,
        id: "thread_...",
        metadata: %{"key_1" => "value 1", "key_2" => "value 2", "key_3" => "value 3"},
        object: "thread"
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/threads/modifyThread
  """
  def threads_modify(thread_id, params, config \\ %Config{})
    when is_bitstring(thread_id) and is_list(params) and is_struct(config)
  do
    Threads.update(thread_id, params, config)
  end

  @doc """
  Deletes a thread.

  ## Example request
  ```elixir
      OpenAI.threads_delete("thread_...")
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        deleted: true,
        id: "thread_...",
        object: "thread.deleted"
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/threads/deleteThread
  """
  def threads_delete(thread_id, config \\ %Config{})
    when is_bitstring(thread_id) and is_struct(config)
  do
    Threads.delete(thread_id, config)
  end

  @doc """
  Retrieves the list of messages associated with a particular thread.

  ## Example request
  ```elixir
      OpenAI.thread_messages("thread_...")
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        data: [
          %{
            "assistant_id" => nil,
            "content" => [
              %{
                "text" => %{
                  "annotations" => [],
                  "value" => "How does AI work? Explain it in simple terms."
                },
                "type" => "text"
              }
            ],
            "created_at" => 1699705727,
            "file_ids" => [],
            "id" => "msg_...",
            "metadata" => %{},
            "object" => "thread.message",
            "role" => "user",
            "run_id" => nil,
            "thread_id" => "thread_..."
          },
          ...
        ],
        first_id: "msg_...",
        has_more: false,
        last_id: "msg_...",
        object: "list"
      }}
  ```

  Retrieves the list of messages associated with a particular thread, filtered
  by query params.

  ## Example request
  ```elixir
      OpenAI.thread_messages("thread_...", after: "msg_...")
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        data: [
          %{
            "assistant_id" => nil,
            "content" => [
              %{
                "text" => %{"annotations" => [], "value" => "Hello, what is AI?"},
                "type" => "text"
              }
            ],
            "created_at" => 1699705727,
            "file_ids" => ["file-..."],
            "id" => "msg_...",
            "metadata" => %{},
            "object" => "thread.message",
            "role" => "user",
            "run_id" => nil,
            "thread_id" => "thread_..."
          }
        ],
        first_id: "msg_...",
        has_more: false,
        last_id: "msg_...",
        object: "list"
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/messages/listMessages
  """
  def thread_messages(thread_id, params \\ [], config \\ %Config{})
    when is_bitstring(thread_id) and is_list(params) and is_struct(config)
  do
    Threads.Messages.fetch(thread_id, params, config)
  end

  @doc """
  Retrieves a thread message by its id.

  ## Example request
  ```elixir
      OpenAI.thread_message("thread_...", "msg_...")
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        assistant_id: nil,
        content: [
          %{
            "text" => %{"annotations" => [], "value" => "Hello, what is AI?"},
            "type" => "text"
          }
        ],
        created_at: 1699705727,
        file_ids: ["file-..."],
        id: "msg_...",
        metadata: %{},
        object: "thread.message",
        role: "user",
        run_id: nil,
        thread_id: "thread_..."
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/threads/getThread
  """
  def thread_message(thread_id, message_id, config \\ %Config{})
    when is_bitstring(thread_id) and is_bitstring(message_id) and is_struct(config)
  do
    Threads.Messages.fetch_by_id(thread_id, message_id, config)
  end

  @doc """
  Creates a message within a thread.

  ## Example request
  ```elixir
      params = [
        role: "user",
        content: "Hello, what is AI?",
        file_ids: ["file-9Riyo515uf9KVfwdSrIQiqtC"],
        metadata: %{
          key_1: "value 1",
          key_2: "value 2"
        }
      ]

      OpenAI.thread_message_create("thread_...", params)
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        assistant_id: nil,
        content: [
          %{
            "text" => %{"annotations" => [], "value" => "Hello, what is AI?"},
            "type" => "text"
          }
        ],
        created_at: 1699706818,
        file_ids: ["file-..."],
        id: "msg_...",
        metadata: %{"key_1" => "value 1", "key_2" => "value 2"},
        object: "thread.message",
        role: "user",
        run_id: nil,
        thread_id: "thread_..."
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/messages/createMessage
  """
  def thread_message_create(thread_id, params, config \\ %Config{})
    when is_bitstring(thread_id) and is_list(params) and is_struct(config)
  do
    Threads.Messages.create(thread_id, params, config)
  end

  @doc """
  Modifies an existing thread message.

  ## Example request
  ```elixir
      params = [
        metadata: %{
          key_3: "value 3"
        }
      ]

      OpenAI.thread_message_modify("thread_...", "msg_...", params)
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        assistant_id: nil,
        content: [
          %{
            "text" => %{"annotations" => [], "value" => "Hello, what is AI?"},
            "type" => "text"
          }
        ],
        created_at: 1699706818,
        file_ids: ["file-..."],
        id: "msg_...",
        metadata: %{"key_1" => "value 1", "key_2" => "value 2", "key_3" => "value 3"},
        object: "thread.message",
        role: "user",
        run_id: nil,
        thread_id: "thread_..."
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/messages/modifyMessage
  """
  def thread_message_modify(thread_id, message_id, params, config \\ %Config{})
    when is_bitstring(thread_id) and is_bitstring(message_id) and is_list(params) and is_struct(config)
  do
    Threads.Messages.update(thread_id, message_id, params, config)
  end

  @doc """
  Retrieves the list of files associated with a particular message of a thread.

  ## Example request
  ```elixir
      OpenAI.thread_message_files("thread_...", "msg_...")
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        data: [
          %{
            "created_at" => 1699706818,
            "id" => "file-...",
            "message_id" => "msg_...",
            "object" => "thread.message.file"
          }
        ],
        first_id: "file-...",
        has_more: false,
        last_id: "file-...",
        object: "list"
      }}
  ```

  Retrieves the list of files associated with a particular message of a thread,
  filtered by query params.

  ## Example request
  ```elixir
      OpenAI.thread_message_files("thread_...", "msg_...", after: "file-...")
  ```

  ## Example response
  ```elixir
      {:ok, %{data: [], first_id: nil, has_more: false, last_id: nil, object: "list"}}
  ```

  See: https://platform.openai.com/docs/api-reference/messages/listMessageFiles
  """
  def thread_message_files(thread_id, message_id, params \\ [], config \\ %Config{})
    when is_bitstring(thread_id) and is_bitstring(message_id) and is_list(params)
     and is_struct(config)
  do
    Threads.Messages.Files.fetch(thread_id, message_id, params, config)
  end

  @doc """
  Retrieves the message file object.

  ## Example request
  ```elixir
      OpenAI.thread_message_file("thread_...", "msg_...", "file-...")
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        created_at: 1699706818,
        id: "file-...",
        message_id: "msg_...",
        object: "thread.message.file"
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/messages/getMessageFile
  """
  def thread_message_file(thread_id, message_id, file_id, config \\ %Config{})
    when is_bitstring(thread_id) and is_bitstring(message_id) and is_bitstring(file_id)
     and is_struct(config)
  do
    Threads.Messages.Files.fetch_by_id(thread_id, message_id, file_id, config)
  end

  @doc """
  Retrieves the list of runs associated with a particular thread.

  ## Example request
  ```elixir
      OpenAI.thread_runs("thread_...")
  ```

  ## Example response
  ```elixir
      {:ok, %{data: [], first_id: nil, has_more: false, last_id: nil, object: "list"}}
  ```

  Retrieves the list of runs associated with a particular thread, filtered
  by query params.

  ## Example request
  ```elixir
      OpenAI.thread_runs("thread_...", limit: 10)
  ```

  ## Example response
  ```elixir
      {:ok, %{data: [], first_id: nil, has_more: false, last_id: nil, object: "list"}}
  ```

  See: https://platform.openai.com/docs/api-reference/runs/listRuns
  """
  def thread_runs(thread_id, params \\ [], config \\ %Config{})
    when is_bitstring(thread_id) and is_list(params) and is_struct(config)
  do
    Threads.Runs.fetch(thread_id, params, config)
  end

  @doc """
  Retrieves a particular thread run by its id.

  ## Example request
  ```elixir
      OpenAI.thread_run("thread_...")
  ```

  ## Example response
  ```elixir
      {:ok, %{data: [], first_id: nil, has_more: false, last_id: nil, object: "list"}}
  ```

  See: https://platform.openai.com/docs/api-reference/runs/getRun
  """
  def thread_run(thread_id, run_id, config \\ %Config{})
    when is_bitstring(thread_id) and is_bitstring(run_id) and is_struct(config)
  do
    Threads.Runs.fetch_by_id(thread_id, run_id, config)
  end

  @doc """
  Creates a run for a thread using a particular assistant.

  ## Example request
  ```elixir
      params = [
        assistant_id: "asst_...",
        model: "gpt-4-1106-preview",
        tools: [%{
          "type" => "retrieval"
        }]
      ]

      OpenAI.thread_run_create("thread_...", params)
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        assistant_id: "asst_...",
        cancelled_at: nil,
        completed_at: nil,
        created_at: 1699711115,
        expires_at: 1699711715,
        failed_at: nil,
        file_ids: ["file-..."],
        id: "run_...",
        instructions: "...",
        last_error: nil,
        metadata: %{},
        model: "gpt-4-1106-preview",
        object: "thread.run",
        started_at: nil,
        status: "queued",
        thread_id: "thread_...",
        tools: [%{"type" => "retrieval"}]
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/runs/createRun
  """
  def thread_run_create(thread_id, params, config \\ %Config{})
    when is_bitstring(thread_id) and is_list(params) and is_struct(config)
  do
    Threads.Runs.create(thread_id, params, config)
  end

  @doc """
  Modifies an existing thread run.

  ## Example request
  ```elixir
      params = [
        metadata: %{
          key_3: "value 3"
        }
      ]

      OpenAI.thread_run_modify("thread_...", "run_...", params)
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        assistant_id: "asst_...",
        cancelled_at: nil,
        completed_at: 1699711125,
        created_at: 1699711115,
        expires_at: nil,
        failed_at: nil,
        file_ids: ["file-..."],
        id: "run_...",
        instructions: "...",
        last_error: nil,
        metadata: %{"key_3" => "value 3"},
        model: "gpt-4-1106-preview",
        object: "thread.run",
        started_at: 1699711115,
        status: "expired",
        thread_id: "thread_...",
        tools: [%{"type" => "retrieval"}]
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/runs/modifyRun
  """
  def thread_run_modify(thread_id, run_id, params, config \\ %Config{})
    when is_bitstring(thread_id) and is_bitstring(run_id) and is_list(params)
     and is_struct(config)
  do
    Threads.Runs.update(thread_id, run_id, params, config)
  end

  @doc """
  Cancels an `in_progress` run.

  ## Example request
  ```elixir
      OpenAI.thread_run_cancel("thread_...", "run_...")
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        assistant_id: "asst_...",
        cancelled_at: nil,
        completed_at: nil,
        created_at: 1699896939,
        expires_at: 1699897539,
        failed_at: nil,
        file_ids: ["file-..."],
        id: "run_...",
        instructions: "...",
        last_error: nil,
        metadata: %{},
        model: "gpt-4-1106-preview",
        object: "thread.run",
        started_at: 1699896939,
        status: "cancelling",
        thread_id: "thread_...",
        tools: [%{"type" => "retrieval"}]
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/runs/cancelRun
  """
  def thread_run_cancel(thread_id, run_id, config \\ %Config{})
    when is_bitstring(thread_id) and is_bitstring(run_id) and is_struct(config)
  do
    Threads.Runs.cancel(thread_id, run_id, config)
  end

  @doc """
  Retrieves the list of steps associated with a particular run of a thread.

  ## Example request
  ```elixir
      OpenAI.thread_run_steps("thread_...", "run_...")
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        data: [
          %{
            "assistant_id" => "asst_...",
            "cancelled_at" => nil,
            "completed_at" => 1699897927,
            "created_at" => 1699897908,
            "expires_at" => nil,
            "failed_at" => nil,
            "id" => "step_...",
            "last_error" => nil,
            "object" => "thread.run.step",
            "run_id" => "run_...",
            "status" => "completed",
            "step_details" => %{
              "message_creation" => %{"message_id" => "msg_..."},
              "type" => "message_creation"
            },
            "thread_id" => "thread_...",
            "type" => "message_creation"
          }
        ],
        first_id: "step_...",
        has_more: false,
        last_id: "step_...",
        object: "list"
      }}
  ```

  Retrieves the list of steps associated with a particular run of a thread,
  filtered by query params.

  ## Example request
  ```elixir
      OpenAI.thread_run_steps("thread_...", "run_...", order: "asc")
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        data: [
          %{
            "assistant_id" => "asst_...",
            "cancelled_at" => nil,
            "completed_at" => 1699897927,
            "created_at" => 1699897908,
            "expires_at" => nil,
            "failed_at" => nil,
            "id" => "step_...",
            "last_error" => nil,
            "object" => "thread.run.step",
            "run_id" => "run_...",
            "status" => "completed",
            "step_details" => %{
              "message_creation" => %{"message_id" => "msg_..."},
              "type" => "message_creation"
            },
            "thread_id" => "thread_...",
            "type" => "message_creation"
          }
        ],
        first_id: "step_...",
        has_more: false,
        last_id: "step_...",
        object: "list"
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/runs/listRunSteps
  """
  def thread_run_steps(thread_id, run_id, params \\ [], config \\ %Config{})
    when is_bitstring(thread_id) and is_bitstring(run_id) and is_list(params)
     and is_struct(config)
  do
    Threads.Runs.Steps.fetch(thread_id, run_id, params, config)
  end

  @doc """
  Retrieves a thread run step by its id.

  ## Example request
  ```elixir
      OpenAI.thread_run_step("thread_...", "run_...", "step_...")
  ```

  ## Example response
  ```elixir
      {:ok,
      %{
        assistant_id: "asst_...",
        cancelled_at: nil,
        completed_at: 1699897927,
        created_at: 1699897908,
        expires_at: nil,
        failed_at: nil,
        id: "step_...",
        last_error: nil,
        object: "thread.run.step",
        run_id: "run_...",
        status: "completed",
        step_details: %{
          "message_creation" => %{"message_id" => "msg_..."},
          "type" => "message_creation"
        },
        thread_id: "thread_...",
        type: "message_creation"
      }}
  ```

  See: https://platform.openai.com/docs/api-reference/runs/getRunStep
  """
  def thread_run_step(thread_id, run_id, step_id, config \\ %Config{})
    when is_bitstring(thread_id) and is_bitstring(run_id) and is_bitstring(step_id)
     and is_struct(config)
  do
    Threads.Runs.Steps.fetch_by_id(thread_id, run_id, step_id, config)
  end

  @doc """
  It returns one or more predicted completions given a prompt.
  The function accepts as arguments the "engine_id" and the set of parameters used by the Completions OpenAI api

  ## Example request
    OpenAI.completions(
      model: "finetuned-model",
      prompt: "once upon a time",
      max_tokens: 5,
      temperature: 1,
      ...
    )

  ## Example response
    {:ok, %{
      choices: [
        %{
          "finish_reason" => "length",
          "index" => 0,
          "logprobs" => nil,
          "text" => "\" thing we are given"
        }
      ],
      created: 1617147958,
      id: "...",
      model: "...",
      object: "text_completion"
      }
    }
  See: https://platform.openai.com/docs/api-reference/completions/create
  """
  def completions(params) when is_list(params),
    do: Completions.fetch(params)

  def completions(params, config) when is_list(params) and is_struct(config),
    do: Completions.fetch(params, config)

  @doc """
  It returns one or more predicted completions given a prompt.
  The function accepts as arguments the "engine_id" and the set of parameters used by the Completions OpenAI api

  ## Example request
      OpenAI.completions(
        "davinci", # engine_id
        prompt: "once upon a time",
        max_tokens: 5,
        temperature: 1,
        ...
      )

  ## Example response
      {:ok, %{
        choices: [
          %{
            "finish_reason" => "length",
            "index" => 0,
            "logprobs" => nil,
            "text" => "\" thing we are given"
          }
        ],
        created: 1617147958,
        id: "...",
        model: "...",
        object: "text_completion"
        }
      }
  See: https://beta.openai.com/docs/api-reference/completions/create for the complete list of parameters you can pass to the completions function
  """
  def completions(engine_id, params) when is_bitstring(engine_id) and is_list(params),
    do: Completions.fetch_by_engine(engine_id, params)

  def completions(engine_id, params, config) when is_bitstring(engine_id),
    do: Completions.fetch_by_engine(engine_id, params, config)

  @doc """
  Creates a completion for the chat message

  ## Example request
      OpenAI.chat_completion(
        model: "gpt-3.5-turbo",
        messages: [
              %{role: "system", content: "You are a helpful assistant."},
              %{role: "user", content: "Who won the world series in 2020?"},
              %{role: "assistant", content: "The Los Angeles Dodgers won the World Series in 2020."},
              %{role: "user", content: "Where was it played?"}
          ]
      )

  ## Example response
      {:ok,
        %{
        choices: [
          %{
            "finish_reason" => "stop",
            "index" => 0,
            "message" => %{
              "content" => "The 2020 World Series was played at Globe Life Field in Arlington, Texas due to the COVID-19 pandemic.",
              "role" => "assistant"
            }
          }
        ],
        created: 1677773799,
        id: "chatcmpl-6pftfA4NO9pOQIdxao6Z4McDlx90l",
        model: "gpt-3.5-turbo-0301",
        object: "chat.completion",
        usage: %{
          "completion_tokens" => 26,
          "prompt_tokens" => 56,
          "total_tokens" => 82
        }
        }
      }


  N.B. to use "stream" mode you must be set http_options as below when you want to treat the chat completion as a stream:

  config :openai,
    api_key: "your-api-key",
    http_options: [recv_timeout: :infinity, stream_to: self(), async: :once]

  ## Example request (stream)
  ```
    OpenAI.chat_completion([
      model: "gpt-3.5-turbo",
      messages: [
        %{role: "system", content: "You are a helpful assistant."},
        %{role: "user", content: "Who won the world series in 2020?"},
        %{role: "assistant", content: "The Los Angeles Dodgers won the World Series in 2020."},
        %{role: "user", content: "Where was it played?"}
      ],
      stream: true, # set this param to true
      ]
    )
    |> Stream.each(fn res ->
      IO.inspect(res)
    end)
    |> Stream.run()
  ```
  ## Example response (stream)
  ```
    %{
      "choices" => [
        %{"delta" => %{"role" => "assistant"}, "finish_reason" => nil, "index" => 0}
      ],
      "created" => 1682700668,
      "id" => "chatcmpl-7ALbIuLju70hXy3jPa3o5VVlrxR6a",
      "model" => "gpt-3.5-turbo-0301",
      "object" => "chat.completion.chunk"
    }

    %{
      "choices" => [
        %{"delta" => %{"content" => "The"}, "finish_reason" => nil, "index" => 0}
      ],
      "created" => 1682700668,
      "id" => "chatcmpl-7ALbIuLju70hXy3jPa3o5VVlrxR6a",
      "model" => "gpt-3.5-turbo-0301",
      "object" => "chat.completion.chunk"
    }
    %{
      "choices" => [
        %{"delta" => %{"content" => " World"}, "finish_reason" => nil, "index" => 0}
      ],
      "created" => 1682700668,
      "id" => "chatcmpl-7ALbIuLju70hXy3jPa3o5VVlrxR6a",
      "model" => "gpt-3.5-turbo-0301",
      "object" => "chat.completion.chunk"
    }
    %{
      "choices" => [
        %{
          "delta" => %{"content" => " Series"},
          "finish_reason" => nil,
          "index" => 0
        }
      ],
      "created" => 1682700668,
      "id" => "chatcmpl-7ALbIuLju70hXy3jPa3o5VVlrxR6a",
      "model" => "gpt-3.5-turbo-0301",
      "object" => "chat.completion.chunk"
    }
    %{
      "choices" => [
        %{"delta" => %{"content" => " in"}, "finish_reason" => nil, "index" => 0}
      ],
      "created" => 1682700668,
      "id" => "chatcmpl-7ALbIuLju70hXy3jPa3o5VVlrxR6a",
      "model" => "gpt-3.5-turbo-0301",
      "object" => "chat.completion.chunk"
    }
  ```

  See: https://platform.openai.com/docs/api-reference/chat/create for the complete list of parameters you can pass to the completions function
  """
  def chat_completion(params, config \\ %Config{}) do
    Chat.fetch(params, config)
  end

  @doc """
  Creates a new edit for the provided input, instruction, and parameters

  ## Example request
  OpenAI.edits(
    model: "text-davinci-edit-001",
    input: "What day of the wek is it?",
    instruction: "Fix the spelling mistakes"
  )

  ## Example response
  {:ok,
  %{
   choices: [%{"index" => 0, "text" => "What day of the week is it?\n"}],
   created: 1675443483,
   object: "edit",
   usage: %{
     "completion_tokens" => 28,
     "prompt_tokens" => 25,
     "total_tokens" => 53
   }
  }}

  See: https://platform.openai.com/docs/api-reference/edits/create
  """
  def edits(params, config \\ %Config{}) do
    Edits.fetch(params, config)
  end

  @doc """
  Creates an embedding vector representing the input text.

  ## Example request
  OpenAI.embeddings(
    model: "text-embedding-ada-002",
    input: "The food was delicious and the waiter..."
  )

  ## Example response
  {:ok,
  %{
   data: [
     %{
       "embedding" => [0.0022523515000000003, -0.009276069000000001,
        0.015758524000000003, -0.007790373999999999, -0.004714223999999999,
        0.014806155000000001, -0.009803046499999999, -0.038323310000000006,
        -0.006844355, -0.028672641, 0.025345700000000002, 0.018145794000000003,
        -0.0035904291999999997, -0.025498080000000003, 5.142790000000001e-4,
        -0.016317246, 0.028444072, 0.0053713582, 0.009631619999999999,
        -0.016469626, -0.015390275, 0.004301531, 0.006984035499999999,
        -0.007079272499999999, -0.003926933, 0.018602932000000003, 0.008666554,
        -0.022717162999999995, 0.011460166999999997, 0.023860006,
        0.015568050999999998, -0.003587254600000001, -0.034843990000000005,
        -0.0041555012999999995, -0.026107594000000005, -0.02151083,
        -0.0057618289999999996, 0.011714132499999998, 0.008355445999999999,
        0.004098358999999999, 0.019199749999999998, -0.014336321, 0.008952264,
        0.0063395994, -0.04576447999999999, ...],
       "index" => 0,
       "object" => "embedding"
     }
   ],
   model: "text-embedding-ada-002-v2",
   object: "list",
   usage: %{"prompt_tokens" => 8, "total_tokens" => 8}
  }}

  See: https://platform.openai.com/docs/api-reference/embeddings/create
  """
  def embeddings(params, config \\ %Config{}) do
    Embeddings.fetch(params, config)
  end

  @doc """
  Transcribes audio into the input language.

  ## Example request
  OpenAI.audio_transcription(
    "./path_to_file/blade_runner.mp3", # file path
    model: "whisper-1"
  )

  ## Example response
  {:ok,
  %{
   text: "I've seen things you people wouldn't believe.."
  }}

  See: https://platform.openai.com/docs/api-reference/audio/create
  """
  def audio_transcription(file_path, params, config \\ %Config{}) do
    Audio.transcription(file_path, params, config)
  end

  @doc """
  Translates audio into into English.

  ## Example request
  OpenAI.audio_translation(
    "./path_to_file/werner_herzog_interview.mp3", # file path
    model: "whisper-1"
  )

  ## Example response
  {:ok,
  %{
    text:  "I thought if I walked, I would be saved. It was almost like a pilgrimage. I will definitely continue to walk long distances. It is a very unique form of life and existence that we have lost almost entirely from our normal life."
  }}

  See: https://platform.openai.com/docs/api-reference/audio/create
  """
  def audio_translation(file_path, params, config \\ %Config{}) do
    Audio.translation(file_path, params, config)
  end

  @doc """
  Classifies if text violates OpenAI's Content Policy

  ## Example request
  OpenAI.moderations(input: "I want to kill everyone!")

  ## Example response
  {:ok,
  %{
   id: "modr-6gEWXyuaU8dqiHpbAHIsdru0zuC88",
   model: "text-moderation-004",
   results: [
     %{
       "categories" => %{
         "hate" => false,
         "hate/threatening" => false,
         "self-harm" => false,
         "sexual" => false,
         "sexual/minors" => false,
         "violence" => true,
         "violence/graphic" => false
       },
       "category_scores" => %{
         "hate" => 0.05119025334715844,
         "hate/threatening" => 0.00321022979915142,
         "self-harm" => 7.337320857914165e-5,
         "sexual" => 1.1111642379546538e-6,
         "sexual/minors" => 3.588798147546868e-10,
         "violence" => 0.9190407395362855,
         "violence/graphic" => 1.2791929293598514e-7
       },
       "flagged" => true
     }
   ]
  }}

  See: https://platform.openai.com/docs/api-reference/moderations/create
  """
  def moderations(params, config \\ %Config{}) do
    Moderations.fetch(params, config)
  end

  @doc """
  List your organization's fine-tuning jobs
  ## Example request
      OpenAI.finetunes()

  ## Example response
      {:ok, %{
        "data" => [
          %{"created_at" => 1614807352, "fine_tuned_model" => "curie:ft-acmeco-2021-03-03-21-44-20", "model": ...},
          ...,
          ...
        ]
      }
  See: https://beta.openai.com/docs/api-reference/fine-tunes/list

  Gets info about the fine-tune job.
  ## Example request
      OpenAI.finetunes("ft-AF1WoRqd3aJAHsqc9NY7iL8F")

  ## Example response
      {:ok, %{
        created_at: 1614807352,
        events: [
          %{
            "created_at" => 1614807352,
            "level" => "info",
            "message" => "Created fine-tune: ft-AF1WoRqd3aJAHsqc9NY7iL8F",
            "object" => "fine-tune-event"
          },
          %{
            "created_at" => 1614807360,
            "level" => "info",
            "message" => "Fine-tune costs $0.02",
            "object" => "fine-tune-event"
          },
          ...,
          ...
      }
  See: https://beta.openai.com/docs/api-reference/fine-tunes/retrieve
  """
  def finetunes(config) when is_struct(config), do: Finetunes.fetch(config)

  def finetunes(finetunes_id) when is_bitstring(finetunes_id),
    do: Finetunes.fetch_by_id(finetunes_id)

  def finetunes(), do: Finetunes.fetch()
  def finetunes(finetune_id, config \\ %Config{}), do: Finetunes.fetch_by_id(finetune_id, config)

  @doc """
  Creates a job that fine-tunes a specified model from a given dataset.

  ## Example request
      OpenAI.finetunes_create(training_file: "file-123", model: "curie", validation_file: "file-456")

  ## Example response

  See: https://platform.openai.com/docs/api-reference/fine-tunes/create
  """
  def finetunes_create(params, config \\ %Config{}) do
    Finetunes.create(params, config)
  end

  @doc """
  Immediately cancel a fine-tune job.

  ## Example request
      OpenAI.finetunes_cancel("ft-AF1WoRqd3aJAHsqc9NY7iL8F")

  ## Example response
  {:ok,
  %{
   created_at: 1675527767,
   events: [
     ...
     %{
       "created_at" => 1675528080,
       "level" => "info",
       "message" => "Fine-tune cancelled",
       "object" => "fine-tune-event"
     }
   ],
   fine_tuned_model: nil,
   hyperparams: %{
     "batch_size" => 1,
     "learning_rate_multiplier" => 0.1,
     "n_epochs" => 4,
     "prompt_loss_weight" => 0.01
   },
   id: "ft-IaBYfSSAK47UUCbebY5tBIEj",
   model: "curie",
   object: "fine-tune",
   organization_id: "org-1iPTOIak4b5fpuIB697AYMmO",
   result_files: [],
   status: "cancelled",
   training_files: [
     %{
       "bytes" => 923,
       "created_at" => 1675373519,
       "filename" => "file123.jsonl",
       "id" => "file-123",
       "object" => "file",
       "purpose" => "fine-tune",
       "status" => "processed",
       "status_details" => nil
     }
   ],
   updated_at: 1675528080,
   validation_files: []
  }}

  See: https://platform.openai.com/docs/api-reference/fine-tunes/cancel
  """
  def finetunes_cancel(finetune_id, config \\ %Config{}) do
    Finetunes.cancel(finetune_id, config)
  end

  @doc """
  Delete a fine-tuned model. You must have the Owner role in your organization.

  ## Example request
      OpenAI.finetunes_delete_model("model-id")

  ## Example response
  {:ok,
  %{
   id: "model-id",
   object: "model",
   deleted: true
  }}

  See: https://platform.openai.com/docs/api-reference/fine-tunes/delete-model
  """
  def finetunes_delete_model(model_id, config \\ %Config{}) do
    Models.delete(model_id, config)
  end

  @doc """
  Get fine-grained status updates for a fine-tune job.

  ## Example request
      OpenAI.finetunes_list_events("ft-AF1WoRqd3aJAHsqc9NY7iL8F")

  ## Example response
  {:ok,
  %{
   data: [
     %{
       "created_at" => 1675376995,
       "level" => "info",
       "message" => "Created fine-tune: ft-123",
       "object" => "fine-tune-event"
     },
     %{
       "created_at" => 1675377104,
       "level" => "info",
       "message" => "Fine-tune costs $0.00",
       "object" => "fine-tune-event"
     },
     %{
       "created_at" => 1675377105,
       "level" => "info",
       "message" => "Fine-tune enqueued. Queue number: 18",
       "object" => "fine-tune-event"
     },
    ...,
     ]
    }
  }

  See: https://platform.openai.com/docs/api-reference/fine-tunes/events
  """
  def finetunes_list_events(finetune_id, config \\ %Config{}) do
    Finetunes.list_events(finetune_id, config)
  end

  @doc """
  This generates an image based on the given prompt.
  Image functions require some times to execute, and API may return a timeout error, if needed you can pass a configuration object with HTTPoison http_options as second argument of the function to increase the timeout.

  ## Example Request
      OpenAI.images_generations(
        [prompt: "A developer writing a test", size: "256x256"],
        %OpenAI.config{http_options: [recv_timeout: 10 * 60 * 1000]} # optional!
      )

  ## Example Response
    {:ok,
      %{
      created: 1670341737,
      data: [
        %{
         "url" => ...Returned url
       }
      ]
    }}
  See: https://beta.openai.com/docs/api-reference/images/create for the complete list of parameters you can pass to the image creation function

  note: the official way of passing http_options changed in v0.5.0 to be compliant with the conventions of other APIs, the alias OpenAI.images_generations(file_path, params, request_options), but is still available for retrocompatibility. If you are using it consider to switch to OpenAI.images_variations(params, config)
  """
  def images_generations(params) do
    Images.Generations.fetch(params)
  end

  def images_generations(params, config) when is_struct(config) do
    Images.Generations.fetch(params, config)
  end

  def images_generations(params, request_options) when is_list(request_options) do
    Images.Generations.fetch_legacy(params, request_options)
  end

  @doc """
  alias of images_generations(params, request_options) - will be deprecated in future releases
  """
  def image_generations(params) do
    Images.Generations.fetch(params)
  end

  def image_generations(params, config) when is_struct(config) do
    Images.Generations.fetch(params, config)
  end

  def image_generations(params, request_options) do
    Images.Generations.fetch(params, request_options)
  end

  @doc """
  This edits an image based on the given prompt.
  Image functions require some times to execute, and API may return a timeout error, if needed you can pass a configuration object with HTTPoison http_options as second argument of the function to increase the timeout.

  ## Example Request
  ```elixir
  OpenAI.images_edits(
    "/home/developer/myImg.png",
    [prompt: "A developer writing a test", "size": "256x256"],
    %OpenAI.config{http_options: [recv_timeout: 10 * 60 * 1000]} # optional!
  )
  ```

  ## Example Response
  ```elixir
  {:ok,
  %{
   created: 1670341737,
   data: [
     %{
       "url" => ...Returned url
     }
   ]
  }}
  ```
  See: https://beta.openai.com/docs/api-reference/images/create-edit for the complete list of parameters you can pass to the image creation function
    note: the official way of passing http_options changed in v0.5.0 to be compliant with the conventions of other APIs, the alias OpenAI.images_edits(file_path, params, request_options), but is still available for retrocompatibility. If you are using it consider to switch to OpenAI.images_edits(file_path, params, config)
  """
  def images_edits(file_path, params) do
    Images.Edits.fetch(file_path, params)
  end

  def images_edits(file_path, params, config) when is_struct(config) do
    Images.Edits.fetch(file_path, params)
  end

  def images_edits(file_path, params, request_options) when is_list(request_options) do
    Images.Edits.fetch_legacy(file_path, params, request_options)
  end

  @doc """
  alias of images_edits(file_path, params, request_options) - will be deprecated in future releases
  """
  def image_edits(file_path, params) do
    Images.Edits.fetch(file_path, params)
  end

  def image_edits(file_path, params, config) when is_struct(config) do
    Images.Edits.fetch(file_path, params)
  end

  def image_edits(file_path, params, request_options) when is_list(request_options) do
    Images.Edits.fetch_legacy(file_path, params, request_options)
  end

  @doc """
  Creates a variation of a given image.
  Image functions require some times to execute, and API may return a timeout error, if needed you can pass a configuration object with HTTPoison http_options as second argument of the function to increase the timeout.

  ## Example Request
  ```elixir
  OpenAI.images_variations(
     "/home/developer/myImg.png",
     [n: "5"],
    %OpenAI.config{http_options: [recv_timeout: 10 * 60 * 1000]} # optional!
  )
  ```

  ## Example Response
  ```elixir
  {:ok,
  %{
   created: 1670341737,
   data: [
     %{
       "url" => ...Returned url
     }
   ]
  }}
  ```
  See: https://beta.openai.com/docs/api-reference/images/create-variation for the complete list of parameters you can pass to the image creation function
    note: the official way of passing http_options changed in v0.5.0 to be compliant with the conventions of other APIs, the alias OpenAI.images_variations(file_path, params, request_options), but is still available for retrocompatibility. If you are using it consider to switch to OpenAI.images_edits(file_path, params, config)
  """
  def images_variations(file_path, params \\ []) do
    Images.Variations.fetch(file_path, params)
  end

  def images_variations(file_path, params, config) when is_struct(config) do
    Images.Variations.fetch(file_path, params, config)
  end

  def images_variations(file_path, params, request_options) when is_list(request_options) do
    Images.Variations.fetch_legacy(file_path, params, request_options)
  end

  @doc """
  alias of images_variations(file_path, params, request_options) - will be deprecated in future releases
  """
  def image_variations(file_path, params \\ []) do
    Images.Variations.fetch(file_path, params)
  end

  def image_variations(file_path, params, config) when is_struct(config) do
    Images.Variations.fetch(file_path, params, config)
  end

  def image_variations(file_path, params, request_options) when is_list(request_options) do
    Images.Variations.fetch_legacy(file_path, params, request_options)
  end

  @doc """
  Returns a list of files that belong to the user's organization.

  ## Example request
  ```elixir
  OpenAI.files()
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
    data: [
      %{
        "bytes" => 123,
        "created_at" => 213,
        "filename" => "file.jsonl",
        "id" => "file-123321",
        "object" => "file",
        "purpose" => "fine-tune",
        "status" => "processed",
        "status_details" => nil
      }
    ],
    object: "list"
    }
  }
  ```
  See: https://platform.openai.com/docs/api-reference/files

  Returns a file that belong to the user's organization, given a file id

  ## Example Request
  ```elixir
  OpenAI.files("file-123321")
  ```

  ## Example Response
  ```elixir
  {:ok,
    %{
      bytes: 923,
      created_at: 1675370979,
      filename: "file.jsonl",
      id: "file-123321",
      object: "file",
      purpose: "fine-tune",
      status: "processed",
      status_details: nil
    }
  }
  ```
  See: https://platform.openai.com/docs/api-reference/files/retrieve
  """
  def files(config) when is_struct(config), do: Files.fetch(config)

  def files(file_id) when is_bitstring(file_id),
    do: Files.fetch_by_id(file_id)

  def files(), do: Files.fetch()
  def files(file_id, config \\ %Config{}), do: Files.fetch_by_id(file_id, config)

  @doc """
  Upload a file that contains document(s) to be used across various endpoints/features. Currently, the size of all the files uploaded by one organization can be up to 1 GB. Please contact OpenAI if you need to increase the storage limit.

  ## Example request
  ```elixir
  OpenAI.files_upload("./file.jsonl", purpose: "fine-tune")
  ```

  ## Example response
  ```elixir
  {:ok,
    %{
      bytes: 923,
      created_at: 1675373519,
      filename: "file.jsonl",
      id: "file-123",
      object: "file",
      purpose: "fine-tune",
      status: "uploaded",
      status_details: nil
    }
  }
  ```
  See: https://platform.openai.com/docs/api-reference/files/upload
  """
  def files_upload(file_path, params, config \\ %Config{}) do
    Files.upload(file_path, params, config)
  end

  @doc """
  delete a file

  ## Example Request
  ```elixir
  OpenAI.files_delete("file-123")
  ```

  ## Example Response
  ```elixir
  {:ok, %{deleted: true, id: "file-123", object: "file"}}
  ```
  See: https://platform.openai.com/docs/api-reference/files/delete
  """
  def files_delete(file_id, config \\ %Config{}) do
    Files.delete(file_id, config)
  end

  @doc """
   @deprecated: "use models instead"
  Get the list of available engines
  ## Example request
      OpenAI.engines()

  ## Example response
      {:ok, %{
        "data" => [
          %{"id" => "davinci", "object" => "engine", "max_replicas": ...},
          ...,
          ...
        ]
      }
  See: https://beta.openai.com/docs/api-reference/engines/list

  Retrieve specific engine info
  ## Example request
      OpenAI.engines("davinci")

  ## Example response
      {:ok, %{
        "id" => "davinci",
        "object" => "engine",
        "max_replicas": ...
      }
      }
  See: https://beta.openai.com/docs/api-reference/engines/retrieve
  """
  def engines(config) when is_struct(config), do: Engines.fetch(config)
  def engines(engine_id) when is_bitstring(engine_id), do: Engines.fetch_by_id(engine_id)
  def engines(), do: Engines.fetch()
  def engines(engine_id, config), do: Engines.fetch_by_id(engine_id, config)
end
