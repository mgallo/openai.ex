defmodule OpenAi do
  @moduledoc """
  Provides API wrappers for OpenAi API
  See https://beta.openai.com/docs/api-reference/introduction for further info on REST endpoints
  """

  alias OpenAi.Answers
  alias OpenAi.Classifications
  alias OpenAi.Completions
  alias OpenAi.Engines
  alias OpenAi.Search
  alias OpenAi.Finetunes
  alias OpenAi.Images
  alias OpenAi.Files
  alias OpenAi.Models
  alias OpenAi.Edits
  alias OpenAi.Embeddings
  alias OpenAi.Moderations
  alias OpenAi.Chat

  @doc """
  Retrieve the list of available models
  ## Example request
      OpenAi.models()

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
  """
  def models do
    Models.fetch()
  end

  @doc """
  Retrieve specific model info
  ## Example request
      OpenAi.models("davinci-search-query")

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
  def models(model_id) do
    Models.fetch(model_id)
  end

  @doc """
  It returns one or more predicted completions given a prompt.
  The function accepts as arguments the "engine_id" and the set of parameters used by the Completions OpenAi api

  ## Example request
      OpenAi.completions(
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
  def completions(params) do
    Completions.fetch(params)
  end

  @doc """
  It returns one or more predicted completions given a prompt.
  The function accepts as arguments the "engine_id" and the set of parameters used by the Completions OpenAi api

  ## Example request
      OpenAi.completions(
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
  def completions(engine_id, params) do
    Completions.fetch(engine_id, params)
  end

  @doc """
  Creates a completion for the chat message

  ## Example request
      OpenAi.chat_completion(
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
  def chat_completion(params) do
    Chat.fetch(params)
  end

  @doc """
  Creates a new edit for the provided input, instruction, and parameters

  ## Example request
  OpenAi.edits(
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
  def edits(params) do
    Edits.fetch(params)
  end

  @doc """
  Creates an embedding vector representing the input text.

  ## Example request
  OpenAi.embeddings(
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
  def embeddings(params) do
    Embeddings.fetch(params)
  end

  @doc """
  The endpoint first searches over provided documents or files to find relevant context. The relevant context is combined with the provided examples and question to create the prompt for completion.
  ## Example request
      OpenAi.answers(
        model: "curie",
        documents: ["Puppy A is happy.", "Puppy B is sad."],
        question: "which puppy is happy?",
        search_model: "ada",
        examples_context: "In 2017, U.S. life expectancy was 78.6 years.",
        examples: [["What is human life expectancy in the United States?", "78 years."]],
        max_tokens: 5
      )

  ## Example response
      {:ok,
        %{
        answers: ["puppy A."],
        completion: "cmpl-2kdRgXcoUfaAXxlPjmZXBT8AlKWfB",
        model: "curie:2020-05-03",
        object: "answer",
        search_model: "ada",
        selected_documents: [
          %{"document" => 0, "text" => "Puppy A is happy. "},
          %{"document" => 1, "text" => "Puppy B is sad. "}
        ]
        }
      }

    See: https://beta.openai.com/docs/api-reference/answers

  """
  def answers(params) do
    Answers.fetch(params)
  end

  @doc """
  Retrieve specific engine info
  ## Example request
      OpenAi.engines("davinci")

  ## Example response
      {:ok, %{
        "id" => "davinci",
        "object" => "engine",
        "max_replicas": ...
      }
      }
  See: https://beta.openai.com/docs/api-reference/engines/retrieve
  """
  def engines(engine_id) do
    Engines.fetch(engine_id)
  end

  @doc """
  @deprecated: "use models instead"
  Get the list of available engines
  ## Example request
      OpenAi.engines()

  ## Example response
      {:ok, %{
        "data" => [
          %{"id" => "davinci", "object" => "engine", "max_replicas": ...},
          ...,
          ...
        ]
      }
  See: https://beta.openai.com/docs/api-reference/engines/list
  """
  def engines do
    Engines.fetch()
  end

  @doc """
  Classifies if text violates OpenAi's Content Policy

  ## Example request
  OpenAi.moderations(input: "I want to kill everyone!")

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
  def moderations(params) do
    Moderations.fetch(params)
  end

  @doc """
  @deprecated: "DEPRECATED by OpenAi"

  It returns a rank of each document passed to the function, based on its semantic similarity to the passed query.
  The function accepts as arguments the engine_id and theset of parameters used by the Search OpenAi api

  ## Example request
      OpenAi.search(
        "babbage", #engine_id
        documents: ["White House", "hospital", "school"],
        query: "the president"
      )

  ## Example response
      {:ok,
        %{
          data: [
            %{"document" => 0, "object" => "search_result", "score" => 218.676},
            %{"document" => 1, "object" => "search_result", "score" => 17.797},
            %{"document" => 2, "object" => "search_result", "score" => 29.65}
          ],
          model: "...",
          object: "list"
        }}
  See: https://beta.openai.com/docs/api-reference/searches for the complete list of parameters you can pass to the search function
  """
  def search(engine_id, params) do
    Search.fetch(engine_id, params)
  end

  @doc """
  @deprecated: "DEPRECATED by OpenAi"

  It returns the most likely label for the query passed to the function.
  The function accepts as arguments a set of parameters that will be passed to the Classifications OpenAi api


  Given a query and a set of labeled examples, the model will predict the most likely label for the query. Useful as a drop-in replacement for any ML classification or text-to-label task.


  ## Example request
      OpenAi.classifications(
        examples: [
          ["A happy moment", "Positive"],
          ["I am sad.", "Negative"],
          ["I am feeling awesome", "Positive"]
        ],
        labels: ["Positive", "Negative", "Neutral"],
        query: "It is a raining day :(",
        search_model: "ada",
        model: "curie"
      )

  ## Example response
      {:ok,
        %{
          completion: "cmpl-2jIXZYg7Buyg1DDRYtozkre50TSMb",
          label: "Negative",
          model: "curie:2020-05-03",
          object: "classification",
          search_model: "ada",
          selected_examples: [
            %{"document" => 1, "label" => "Negative", "text" => "I am sad."},
            %{"document" => 0, "label" => "Positive", "text" => "A happy moment"},
            %{"document" => 2, "label" => "Positive", "text" => "I am feeling awesome"}
          ]
        }
      }

  See: https://beta.openai.com/docs/api-reference/classifications for the complete list of parameters you can pass to the classifications function
  """
  def classifications(params) do
    Classifications.fetch(params)
  end

  @doc """
  List your organization's fine-tuning jobs
  ## Example request
      OpenAi.finetunes()

  ## Example response
      {:ok, %{
        "data" => [
          %{"created_at" => 1614807352, "fine_tuned_model" => "curie:ft-acmeco-2021-03-03-21-44-20", "model": ...},
          ...,
          ...
        ]
      }
  See: https://beta.openai.com/docs/api-reference/fine-tunes/list
  """
  def finetunes do
    Finetunes.fetch()
  end

  @doc """
  Gets info about the fine-tune job.
  ## Example request
      OpenAi.finetunes("ft-AF1WoRqd3aJAHsqc9NY7iL8F")

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
  def finetunes(finetune_id) do
    Finetunes.fetch(finetune_id)
  end

  @doc """
  Creates a job that fine-tunes a specified model from a given dataset.

  ## Example request
      OpenAi.finetunes_create(training_file: "file-123", model: "curie", validation_file: "file-456")

  ## Example response

  See: https://platform.openai.com/docs/api-reference/fine-tunes/create
  """
  def finetunes_create(params) do
    Finetunes.create(params)
  end

  @doc """
  Immediately cancel a fine-tune job.

  ## Example request
      OpenAi.finetunes_cancel("ft-AF1WoRqd3aJAHsqc9NY7iL8F")

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
  def finetunes_cancel(finetune_id) do
    Finetunes.cancel(finetune_id)
  end

  @doc """
  Delete a fine-tuned model. You must have the Owner role in your organization.

  ## Example request
      OpenAi.finetunes_delete_model("model-id")

  ## Example response
  {:ok,
  %{
   id: "model-id",
   object: "model",
   deleted: true
  }}

  See: https://platform.openai.com/docs/api-reference/fine-tunes/delete-model
  """
  def finetunes_delete_model(model_id) do
    Models.delete(model_id)
  end

  @doc """
  Get fine-grained status updates for a fine-tune job.

  ## Example request
      OpenAi.finetunes_list_events("ft-AF1WoRqd3aJAHsqc9NY7iL8F")

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
  def finetunes_list_events(finetune_id) do
    Finetunes.list_events(finetune_id)
  end

  @doc """
  This generates an image based on the given prompt.
  If needed, you can pass a second argument to the function to add specific http options to this specific call (i.e. increasing the timeout)

  ## Example Request
      OpenAi.images_generations(
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
  def images_generations(params, request_options) do
    Images.Generations.fetch(params, request_options)
  end

  @doc """
  alias of images_generations(params, request_options) - will be deprecated in future releases
  """
  def image_generations(params, request_options) do
    Images.Generations.fetch(params, request_options)
  end

  @doc """
  This edits an image based on the given prompt.

  ## Example Request
  ```elixir
  OpenAi.images_edits(
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
  def images_edits(file_path, params, request_options \\ []) do
    Images.Edits.fetch(file_path, params, request_options)
  end

  @doc """
  alias of images_edits(file_path, params, request_options) - will be deprecated in future releases
  """
  def image_edits(file_path, params, request_options \\ []) do
    Images.Edits.fetch(file_path, params, request_options)
  end

  @doc """
  Creates a variation of a given image.
  If needed, you can pass a second argument to the function to add specific http options to this specific call (i.e. increasing the timeout)

  ## Example Request
  ```elixir
  OpenAi.images_variations(
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
  def images_variations(file_path, params \\ [], request_options \\ []) do
    Images.Variations.fetch(file_path, params, request_options)
  end

  @doc """
  alias of images_variations(file_path, params, request_options) - will be deprecated in future releases
  """
  def image_variations(file_path, params \\ [], request_options \\ []) do
    Images.Variations.fetch(file_path, params, request_options)
  end

  @doc """
  Returns a list of files that belong to the user's organization.

  ## Example request
  ```elixir
  OpenAi.files()
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
  """
  def files do
    Files.fetch()
  end

  @doc """
  Returns a file that belong to the user's organization, given a file id

  ## Example Request
  ```elixir
  OpenAi.files("file-123321")
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
  def files(file_id) do
    Files.fetch(file_id)
  end

  @doc """
  Upload a file that contains document(s) to be used across various endpoints/features. Currently, the size of all the files uploaded by one organization can be up to 1 GB. Please contact OpenAi if you need to increase the storage limit.

  ## Example request
  ```elixir
  OpenAi.files_upload("./file.jsonl", purpose: "fine-tune")
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
  def files_upload(file_path, params) do
    Files.upload(file_path, params)
  end

  @doc """
  delete a file

  ## Example Request
  ```elixir
  OpenAi.files_delete("file-123")
  ```

  ## Example Response
  ```elixir
  {:ok, %{deleted: true, id: "file-123", object: "file"}}
  ```
  See: https://platform.openai.com/docs/api-reference/files/delete
  """
  def files_delete(file_id) do
    Files.delete(file_id)
  end
end
