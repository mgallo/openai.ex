defmodule OpenAI do
  @moduledoc """
  Provides API wrappers for OpenAI API
  See https://beta.openai.com/docs/api-reference/introduction for further info on REST endpoints
  """

  use Application

  alias OpenAI.Config
  alias OpenAI.Answers
  alias OpenAI.Classifications
  alias OpenAI.Completions
  alias OpenAI.Engines
  alias OpenAI.Search
  alias OpenAI.Finetunes
  alias OpenAI.Images

  def start(_type, _args) do
    children = [Config]
    opts = [strategy: :one_for_one, name: OpenAI.Supervisor]

    Supervisor.start_link(children, opts)
  end

  @doc """
  The endpoint first searches over provided documents or files to find relevant context. The relevant context is combined with the provided examples and question to create the prompt for completion.
  ## Example request
      OpenAI.answers(
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
  def engines(engine_id) do
    Engines.fetch(engine_id)
  end

  @doc """
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
  """
  def engines do
    Engines.fetch()
  end

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
  def completions(engine_id, params) do
    Completions.fetch(engine_id, params)
  end

  @doc """
  It returns a rank of each document passed to the function, based on its semantic similarity to the passed query.
  The function accepts as arguments the engine_id and theset of parameters used by the Search OpenAI api
  
  ## Example request
      OpenAI.search(
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
  It returns the most likely label for the query passed to the function.
  The function accepts as arguments a set of parameters that will be passed to the Classifications OpenAI api
  
  
  Given a query and a set of labeled examples, the model will predict the most likely label for the query. Useful as a drop-in replacement for any ML classification or text-to-label task.
  
  
  ## Example request
      OpenAI.classifications(
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
  """
  def finetunes do
    Finetunes.fetch()
  end

  @doc """
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
  def finetunes(finetune_id) do
    Finetunes.fetch(finetune_id)
  end

  @doc """
  This generates an image based on the given prompt.
  If needed, you can pass a second argument to the function to add specific http options to this specific call (i.e. increasing the timeout)
  
  ## Example Request
      OpenAI.Images.Generations.fetch(
        [prompt: "A developer writing a test", size: "256x256"],
         recv_timeout: 10 * 60 * 1000
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

  def image_generations(params, request_options) do
    Images.Generations.fetch(params, request_options)
  end

  @doc """
  This edits an image based on the given prompt.
  If needed, you can pass a second argument to the function to add specific http options to this specific call (i.e. increasing the timeout)
  
  ## Example Request
  ```elixir
  OpenAI.image_edits(
     "/home/developer/myImg.png",
    { "prompt", "A developer writing a test", "size": "256x256"},
     recv_timeout: 10 * 60 * 1000
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

  def image_edits(file_path, params, request_options) do
    Images.Edits.fetch(file_path, params, request_options)
  end

  @doc """
  This generates an image based on the given prompt.
  If needed, you can pass a second argument to the function to add specific http options to this specific call (i.e. increasing the timeout)
  
  ## Example Request
  ```elixir
  OpenAI.image_variations(
     "/home/developer/myImg.png",
    { "prompt", "A developer writing a test", "size": "256x256"},
     recv_timeout: 10 * 60 * 1000
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

  def image_variations(file_path, params, request_options) do
    Images.Variations.fetch(file_path, params, request_options)
  end

  # TODO: files apis
  # def files do
  # end

  # def upload_file do
  # end

  # def delete_file do
  # end
end
