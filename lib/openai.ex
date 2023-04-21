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
  def completions(params, config \\ %Config{}) when is_list(params),
    do: Completions.fetch(params, config)

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
  
  Known issue: the stream param is not working properly in the current implementation
  
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
  If needed, you can pass a second argument to the function to add specific http options to this specific call (i.e. increasing the timeout)
  
  ## Example Request
      OpenAI.images_generations(
        [prompt: "A developer writing a test", size: "256x256"],
        [recv_timeout: 10 * 60 * 1000]
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
  """
  def images_generations(params, config \\ %Config{}) do
    Images.Generations.fetch(params, config)
  end

  @doc """
  This edits an image based on the given prompt.
  
  ## Example Request
  ```elixir
  OpenAI.images_edits(
    "/home/developer/myImg.png",
    [prompt: "A developer writing a test", "size": "256x256"],
    [recv_timeout: 10 * 60 * 1000]
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
  """
  def images_edits(file_path, params, config \\ %Config{}) do
    Images.Edits.fetch(file_path, params, config)
  end

  @doc """
  Creates a variation of a given image.
  If needed, you can pass a second argument to the function to add specific http options to this specific call (i.e. increasing the timeout)
  
  ## Example Request
  ```elixir
  OpenAI.images_variations(
     "/home/developer/myImg.png",
     [n: "5"],
     [recv_timeout: 10 * 60 * 1000]
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
  """
  def images_variations(file_path, params \\ [], config \\ %Config{}) do
    Images.Variations.fetch(file_path, params, config)
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
end
