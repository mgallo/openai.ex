# Openai.ex
Provides wrappers for OpenAI REST APIs
See https://beta.openai.com/docs/api-reference/introduction for further info on REST endpoints


## Installation
Add ***:openai*** as a dependency in your mix.exs file.

```elixir
def deps do
  [
    {:openai, "~> 0.1.0"}
  ]
end
```

## Configuration
You can configure openai in your mix config.exs (default $project_root/config/config.exs). If you're using Phoenix add the configuration in your config/dev.exs|test.exs|prod.exs files. An example config is:

```elixir
use Mix.Config

config :openai,
  api_key: "your-api-key" # find it at https://beta.openai.com/account/api-keys
  orgainization_key: "your-organization-key" # find it at https://beta.openai.com/account/api-keys

```

## Usage overview
Get your API key from https://beta.openai.com/docs/developer-quickstart/your-api-keys


### engines()
Get the list of available engines
#### Example request
```elixir
OpenAI.engines()
```

#### Example response
```elixir
{:ok, %{
  "data" => [
    %{"id" => "davinci", "object" => "engine", "max_replicas": ...},
    ...,
    ...
  ]
}
```
See: https://beta.openai.com/docs/api-reference/engines/list


### engines(engine_id)
Retrieve specific engine info
#### Example request
```elixir
OpenAI.engines("davinci")
```

#### Example respone
```elixir
{:ok, %{
    "id" => "davinci",
    "object" => "engine",
    "max_replicas": ...
  }
}
```
See: https://beta.openai.com/docs/api-reference/engines/retrieve

### completions(engine_id, params)
It returns one or more predicted completions given a prompt.
The function accepts as arguments the "engine_id" and the set of parameters used by the Completions OpenAI api.

#### Example request
```elixir
  OpenAI.completions(
    "davinci", # engine_id
    prompt: "once upon a time",
    max_tokens: 5,
    temperature: 1,
    ...
)

```

#### Example response
```elixir
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
```
See: https://beta.openai.com/docs/api-reference/completions/create for the complete list of parameters you can pass to the completions function

### search(engine_id, params)
It returns a rank of each document passed to the function, based on its semantic similarity to the passed query.
The function accepts as arguments the engine_id and theset of parameters used by the Search OpenAI api

#### Example request
```elixir
OpenAI.search(
  "babbage", #engine_id
  documents: ["White House", "hospital", "school"],
  query: "the president"
)
```

#### Example response
```elixir
{:ok,
  %{
    data: [
      %{"document" => 0, "object" => "search_result", "score" => 218.676},
      %{"document" => 1, "object" => "search_result", "score" => 17.797},
      %{"document" => 2, "object" => "search_result", "score" => 29.65}
    ],
    model: "...",
    object: "list"
  }
}
```
  See: https://beta.openai.com/docs/api-reference/searches for the complete list of parameters you can pass to the search function


### classifications(params)
It returns the most likely label for the query passed to the function.
The function accepts as arguments a set of parameters that will be passed to the Classifications OpenAI api

Given a query and a set of labeled examples, the model will predict the most likely label for the query. Useful as a drop-in replacement for any ML classification or text-to-label task.

#### Example request
```elixir
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
```

#### Example response
``` elixir
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
```
See: https://beta.openai.com/docs/api-reference/classifications for the complete list of parameters you can pass to the classifications function


### answers(params)
The endpoint first searches over provided documents or files to find relevant context. The relevant context is combined with the provided examples and question to create the prompt for completion.

#### Example request
```elixir
OpenAI.answers(
  model: "curie",
  documents: ["Puppy A is happy.", "Puppy B is sad."],
  question: "which puppy is happy?",
  search_model: "ada",
  examples_context: "In 2017, U.S. life expectancy was 78.6 years.",
  examples: [["What is human life expectancy in the United States?", "78 years."]],
  max_tokens: 5
)
```
#### Example response
```elixir
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
```

See: https://beta.openai.com/docs/api-reference/answers

## TODO:
[] integrate file apis

## License
The package is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).




