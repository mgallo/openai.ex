# Openai.ex
[![Hex.pm Version](https://img.shields.io/hexpm/v/openai)](https://hex.pm/packages/openai)
[![Hex.pm Download Total](https://img.shields.io/hexpm/dt/openai)](https://hex.pm/packages/openai)

Unofficial community-maintained wrapper for OpenAI REST APIs
See https://platform.openai.com/docs/api-reference/introduction for further info on REST endpoints


## Installation
Add ***:openai*** as a dependency in your mix.exs file.

```elixir
def deps do
  [
    {:openai, "~> 0.5.2"}
  ]
end
```

## Configuration
You can configure openai in your mix config.exs (default $project_root/config/config.exs). If you're using Phoenix add the configuration in your config/dev.exs|test.exs|prod.exs files. An example config is:

```elixir
import Config

config :openai,
  # find it at https://platform.openai.com/account/api-keys
  api_key: "your-api-key",
  # find it at https://platform.openai.com/account/org-settings under "Organization ID"
  organization_key: "your-organization-key",
  # optional, use when required by an OpenAI API beta, e.g.:
  beta: "assistants=v1"
  # optional, passed to [HTTPoison.Request](https://hexdocs.pm/httpoison/HTTPoison.Request.html) options
  http_options: [recv_timeout: 30_000],
  # optional, useful if you want to do local integration tests using Bypass or similar
  # (https://github.com/PSPDFKit-labs/bypass), do not use it for production code,
  # but only in your test config!
  api_url: "http://localhost/"

```
Note: you can load your os ENV variables in the configuration file, if you set an env variable for API key named `OPENAI_API_KEY` you can get it in the code by doing `System.get_env("OPENAI_API_KEY")`.

⚠️`config.exs` is compile time, so the `get_env/1` function is executed during the build, if you want to get the env variables during runtime please use `runtime.exs` instead of `config.exs` in your application ([elixir doc ref](https://elixir-lang.org/getting-started/mix-otp/config-and-releases.html#configuration)).

## Configuration override
Client library configuration can be overwritten in runtime by passing a `%OpenAI.Config{}` struct as last argument of the function you need to use. For instance if you need to use a different `api_key`, `organization_key` or `http_options` you can simply do:

```elixir
config_override = %OpenAI.Config{ api_key: "test-api-key" } # this will return a config struct with "test-api-key" as api_key, all the other config are defaulted by the client by using values taken from config.exs, so you don't need to set the defaults manually

# chat_completion with overriden config
OpenAI.chat_completion([
  model: "gpt-3.5-turbo",
  messages: [
        %{role: "system", content: "You are a helpful assistant."},
        %{role: "user", content: "Who won the world series in 2020?"},
        %{role: "assistant", content: "The Los Angeles Dodgers won the World Series in 2020."},
        %{role: "user", content: "Where was it played?"}
    ]
  ],
  config_override # <--- pass the overriden configuration as last argument of the function
)


# chat_completion with standard config
OpenAI.chat_completion(
  model: "gpt-3.5-turbo",
  messages: [
      %{role: "system", content: "You are a helpful assistant."},
      %{role: "user", content: "Who won the world series in 2020?"},
      %{role: "assistant", content: "The Los Angeles Dodgers won the World Series in 2020."},
      %{role: "user", content: "Where was it played?"}
  ]
)
```

you can perform a config override in all the functions, note that `params` argument must be passed explicitly as a list in square brackets if the configuration is to be overwritten, as in the example above.

## Usage overview
Get your API key from https://platform.openai.com/account/api-keys

### models()
Retrieve the list of available models
### Example request
```elixir
OpenAI.models()
```
#### Example response
```elixir
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
```
See: https://platform.openai.com/docs/api-reference/models/list

### models(model_id)
Retrieve specific model info

```elixir
OpenAI.models("davinci-search-query")
```
#### Example response
```elixir
{:ok,
 %{
   created: 1651172505,
   id: "davinci-search-query",
   object: "model",
   owned_by: "openai-dev",
   parent: nil,
   permission: [
     %{
       "allow_create_engine" => false,
       "allow_fine_tuning" => false,
       "allow_logprobs" => true,
       "allow_sampling" => true,
       "allow_search_indices" => true,
       "allow_view" => true,
       "created" => 1669066353,
       "group" => nil,
       "id" => "modelperm-lYkiTZMmJMWm8jvkPx2duyHE",
       "is_blocking" => false,
       "object" => "model_permission",
       "organization" => "*"
     }
   ],
   root: "davinci-search-query"
 }}
```
See: https://platform.openai.com/docs/api-reference/models/retrieve

### completions(params)
It returns one or more predicted completions given a prompt.
The function accepts as arguments the "engine_id" and the set of parameters used by the Completions OpenAI api

#### Example request
```elixir
  OpenAI.completions(
    model: "finetuned-model",
    prompt: "once upon a time",
    max_tokens: 5,
    temperature: 1,
    ...
  )
```
#### Example response
```elixir
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
```
See: https://platform.openai.com/docs/api-reference/completions/create

### completions(engine_id, params) (DEPRECATED)
this API has been deprecated by OpenAI, as `engines` are replaced by `models`. If you are using it consider to switch to `completions(params)` ASAP!

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


### chat_completion()
Creates a completion for the chat message

#### Example request
```elixir
OpenAI.chat_completion(
  model: "gpt-3.5-turbo",
  messages: [
        %{role: "system", content: "You are a helpful assistant."},
        %{role: "user", content: "Who won the world series in 2020?"},
        %{role: "assistant", content: "The Los Angeles Dodgers won the World Series in 2020."},
        %{role: "user", content: "Where was it played?"}
    ]
)
```

#### Example response
```elixir
{:ok,
     %{
       choices: [
         %{
           "finish_reason" => "stop",
           "index" => 0,
           "message" => %{
             "content" =>
               "The 2020 World Series was played at Globe Life Field in Arlington, Texas due to the COVID-19 pandemic.",
             "role" => "assistant"
           }
         }
       ],
       created: 1_677_773_799,
       id: "chatcmpl-6pftfA4NO9pOQIdxao6Z4McDlx90l",
       model: "gpt-3.5-turbo-0301",
       object: "chat.completion",
       usage: %{
         "completion_tokens" => 26,
         "prompt_tokens" => 56,
         "total_tokens" => 82
       }
     }}
```

See: https://platform.openai.com/docs/api-reference/chat/create for the complete list of parameters you can pass to the completions function

### chat_completion() with stream
Creates a completion for the chat message

#### Example request
```elixir
import Config

config :openai,
  api_key: "your-api-key",
  http_options: [recv_timeout: :infinity, stream_to: self(), async: :once],
  ...
```

`http_options` must be set as above when you want to treat the chat completion as a stream.

```elixir
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

#### Example response
```elixir
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
...
```

### edits()
Creates a new edit for the provided input, instruction, and parameters

#### Example request
```elixir
OpenAI.edits(
  model: "text-davinci-edit-001",
  input: "What day of the wek is it?",
  instruction: "Fix the spelling mistakes"
)
```
#### Example response
```elixir
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
```
See: https://platform.openai.com/docs/api-reference/edits/create

### images_generations(params)
This generates an image based on the given prompt.
Image functions require some times to execute, and API may return a timeout error, if needed you can pass an optional configuration struct with HTTPoison http_options as second argument of the function to increase the timeout.

#### Example request
```elixir
OpenAI.images_generations(
    [prompt: "A developer writing a test", size: "256x256"],
    %OpenAI.Config{http_options: [recv_timeout: 10 * 60 * 1000]} # optional!
 )
```

#### Example response
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

Note: this api signature has changed in `v0.3.0` to be compliant with the conventions of other APIs, the alias `OpenAI.image_generations(params, request_options)` is still available for retrocompatibility. If you are using it consider to switch to `OpenAI.images_generations(params, request_options)` ASAP.

Note2: the official way of passing http_options changed in `v0.5.0` to be compliant with the conventions of other APIs, the alias `OpenAI.images_generations(file_path, params, request_options)`, but is still available for retrocompatibility. If you are using it consider to switch to `OpenAI.images_variations(params, config)`


See: https://platform.openai.com/docs/api-reference/images/create

### images_edits(file_path, params)
Edit an existing image based on prompt
Image functions require some times to execute, and API may return a timeout error, if needed you can pass an optional configuration struct with HTTPoison http_options as second argument of the function to increase the timeout.

#### Example Request
```elixir
OpenAI.images_edits(
     "/home/developer/myImg.png",
     [prompt: "A developer writing a test", size: "256x256"],
    %OpenAI.Config{http_options: [recv_timeout: 10 * 60 * 1000]} # optional!
 )
```

#### Example Response
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
Note: the official way of passing http_options changed in `v0.5.0` to be compliant with the conventions of other APIs, the alias `OpenAI.images_edits(file_path, params, request_options)`, but is still available for retrocompatibility. If you are using it consider to switch to `OpenAI.images_edits(file_path, params, config)`

See: https://platform.openai.com/docs/api-reference/images/create-edit

### images_variations(file_path, params)
Image functions require some times to execute, and API may return a timeout error, if needed you can pass an optional configuration struct with HTTPoison http_options as second argument of the function to increase the timeout.

#### Example Request
```elixir
OpenAI.images_variations(
    "/home/developer/myImg.png",
    [n: "5"],
    %OpenAI.Config{http_options: [recv_timeout: 10 * 60 * 1000]} # optional!
)
```

#### Example Response
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

Note: the official way of passing http_options changed in `v0.5.0` to be compliant with the conventions of other APIs, the alias `OpenAI.images_variations(file_path, params, request_options)`, but is still available for retrocompatibility. If you are using it consider to switch to `OpenAI.images_edits(file_path, params, config)`

See: https://platform.openai.com/docs/api-reference/images/create-variation

### embeddings(params)

#### Example request
```elixir
OpenAI.embeddings(
    model: "text-embedding-ada-002",
    input: "The food was delicious and the waiter..."
  )
```

#### Example response
```elixir
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
```
See: https://platform.openai.com/docs/api-reference/embeddings/create

### audio_speech(params)
Generates audio from the input text.

#### Example request
```elixir
OpenAI.audio_speech(
  model: "tts-1",
  input: "You know that Voight-Kampf test of yours. Did you ever take that test yourself?",
  voice: "alloy"
)
```

#### Example response
```elixir
  {:ok, <<255, 255, ...>>}
```

See: https://platform.openai.com/docs/api-reference/audio/create to get info on the params accepted by the api

### audio_transcription(file_path, params)
Transcribes audio into the input language.

#### Example request
```elixir
OpenAI.audio_transcription(
  "./path_to_file/blade_runner.mp3", # file path
  model: "whisper-1"
)
```

#### Example response
```elixir
 {:ok,
  %{
   text: "I've seen things you people wouldn't believe.."
  }}
```
See: https://platform.openai.com/docs/api-reference/audio/create to get info on the params accepted by the api

### audio_translation(file_path, params)
Translates audio into into English.

#### Example request
```elixir
OpenAI.audio_translation(
  "./path_to_file/werner_herzog_interview.mp3", # file path
  model: "whisper-1"
)
```

#### Example response
```elixir
{:ok,
  %{
    text:  "I thought if I walked, I would be saved. It was almost like a pilgrimage. I will definitely continue to walk long distances. It is a very unique form of life and existence that we have lost almost entirely from our normal life."
  }
}
```
See: https://platform.openai.com/docs/api-reference/audio/create to get info on the params accepted by the api


### files()
Returns a list of files that belong to the user's organization.

#### Example request
```elixir
OpenAI.files()
```
#### Example response
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

### files(file_id)
Returns a file that belong to the user's organization, given a file id

#### Example request
```elixir
OpenAI.files("file-123321")
```

#### Example response
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


### files_upload(file_path, params)
Upload a file that contains document(s) to be used across various endpoints/features. Currently, the size of all the files uploaded by one organization can be up to 1 GB. Please contact OpenAI if you need to increase the storage limit.

#### Example request
```elixir
OpenAI.files_upload("./file.jsonl", purpose: "fine-tune")
```

#### Example response
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

### files_delete(file_id)
delete a file

#### Example request
```elixir
OpenAI.files_delete("file-123")
```

#### Example response
```elixir
{:ok, %{deleted: true, id: "file-123", object: "file"}}
```
See: https://platform.openai.com/docs/api-reference/files/delete


### finetunes()
List your organization's fine-tuning jobs.

#### Example request
```elixir
OpenAI.finetunes()
```

#### Example response
```elixir
{:ok,
  %{
    object: "list",
    data: [%{
      "id" => "t-AF1WoRqd3aJAHsqc9NY7iL8F",
      "object" => "fine-tune",
      "model" => "curie",
      "created_at" => 1614807352,
      "fine_tuned_model" => null,
      "hyperparams" => { ... },
      "organization_id" => "org-...",
      "result_files" = [],
      "status": "pending",
      "validation_files" => [],
      "training_files" => [ { ... } ],
      "updated_at" => 1614807352,
    }],
  }
}
```

See: https://platform.openai.com/docs/api-reference/fine-tunes/list

### finetunes(finetune_id)
Gets info about a fine-tune job.

#### Example request
```elixir
OpenAI.finetunes("t-AF1WoRqd3aJAHsqc9NY7iL8F")
```

#### Example response
```elixir
{:ok,
  %{
    object: "list",
    data: [%{
      "id" => "t-AF1WoRqd3aJAHsqc9NY7iL8F",
      "object" => "fine-tune",
      "model" => "curie",
      "created_at" => 1614807352,
      "fine_tuned_model" => null,
      "hyperparams" => { ... },
      "organization_id" => "org-...",
      "result_files" = [],
      "status": "pending",
      "validation_files" => [],
      "training_files" => [ { ... } ],
      "updated_at" => 1614807352,
    }],
  }
}
```

See: https://platform.openai.com/docs/api-reference/fine-tunes/retrieve

### finetunes_create(params)
Creates a job that fine-tunes a specified model from a given dataset.

#### Example request
```elixir
OpenAI.finetunes_create(
  training_file: "file-123213231",
  model: "curie",
)
```

#### Example response
```elixir
{:ok,
 %{
   created_at: 1675527767,
   events: [
     %{
       "created_at" => 1675527767,
       "level" => "info",
       "message" => "Created fine-tune: ft-IaBYfSSAK47UUCbebY5tBIEj",
       "object" => "fine-tune-event"
     }
   ],
   fine_tuned_model: nil,
   hyperparams: %{
     "batch_size" => nil,
     "learning_rate_multiplier" => nil,
     "n_epochs" => 4,
     "prompt_loss_weight" => 0.01
   },
   id: "ft-IaBYfSSAK47UUCbebY5tBIEj",
   model: "curie",
   object: "fine-tune",
   organization_id: "org-1iPTOIak4b5fpuIB697AYMmO",
   result_files: [],
   status: "pending",
   training_files: [
     %{
       "bytes" => 923,
       "created_at" => 1675373519,
       "filename" => "file-12321323.jsonl",
       "id" => "file-12321323",
       "object" => "file",
       "purpose" => "fine-tune",
       "status" => "processed",
       "status_details" => nil
     }
   ],
   updated_at: 1675527767,
   validation_files: []
 }}
```
See: https://platform.openai.com/docs/api-reference/fine-tunes/create


### finetunes_list_events(finetune_id)
Get fine-grained status updates for a fine-tune job.

#### Example request
```elixir
OpenAI.finetunes_list_events("ft-AF1WoRqd3aJAHsqc9NY7iL8F")
```

#### Example response
```elixir
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
```
See: https://platform.openai.com/docs/api-reference/fine-tunes/events


### finetunes_cancel(finetune_id)
Immediately cancel a fine-tune job.

#### Example request
```elixir
OpenAI.finetunes_cancel("ft-AF1WoRqd3aJAHsqc9NY7iL8F")
```

#### Example response
```elixir
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
```

### finetunes_delete_model(finetune_id)
Immediately cancel a fine-tune job.

#### Example request
```elixir
OpenAI.finetunes_delete_model("model-id")
```

#### Example response
```elixir
{:ok,
  %{
   id: "model-id",
   object: "model",
   deleted: true
  }
}
```
See: https://platform.openai.com/docs/api-reference/fine-tunes/delete-model


### moderations(params)
Classifies if text violates OpenAI's Content Policy

#### Example request
```elixir
OpenAI.moderations(input: "I want to kill everyone!")
```

#### Example response
```elixir
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
```
See: https://platform.openai.com/docs/api-reference/moderations/create

## Beta APIs
The following APIs are currently in beta, to use them be sure to set the `beta` parameter in your config.

```elixir
config :openai,
  # optional, use when required by an OpenAI API beta, e.g.:
  beta: "assistants=v1"
```

### assistants()
Retrieves the list of assistants.

#### Example request
```elixir
OpenAI.assistants()
```
#### Example response
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
See: https://platform.openai.com/docs/api-reference/assistants/listAssistants


### assistants(params)
Retrieves the list of assistants filtered by query params.
  
#### Example request
```elixir
OpenAI.assistants(after: "", limit: 10)
```
#### Example response
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

### assistants(assistant_id)
Retrieves an assistant by its id.
  
#### Example request
```elixir
OpenAI.assistants("asst_...")
```
#### Example response
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

### assistants_create(params)
Creates a new assistant.

#### Example request
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

#### Example response
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


### assistants_modify(assistant_id, params)
Modifies an existing assistant.

#### Example request
```elixir
OpenAI.assistants_modify(
  "asst_...",
  model: "gpt-4-1106-preview",
  name: "My upgraded assistant"
)
```

#### Example response
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

### assistants_delete(assistant_id)
Deletes an assistant.

#### Example request
```elixir
OpenAI.assistants_delete("asst_...")
```

#### Example response
```elixir
{:ok,
%{
  deleted: true,
  id: "asst_...",
  object: "assistant.deleted"
}}
```
See: https://platform.openai.com/docs/api-reference/assistants/deleteAssistant

### assistant_files(assistant_id)
Retrieves the list of files associated with a particular assistant.

#### Example request
```elixir
OpenAI.assistant_files("asst_...")
```

#### Example response
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

### assistant_files(assistant_id, params)
Retrieves the list of files associated with a particular assistant, filtered by query params.

#### Example request
```elixir
OpenAI.assistant_files("asst_...", order: "desc")
```

#### Example response
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

### assistant_file(assistant_id, file_id)
Retrieves an assistant file by its id

#### Example request
```elixir
OpenAI.assistant_file("asst_...", "file_...")
```

#### Example response
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

### assistant_file_create(assistant_id, params)
Attaches a previously uploaded file to the assistant.

#### Example request
```elixir
OpenAI.assistant_file_create("asst_...", file_id: "file-...")
```

#### Example response
```elixir
{:ok,
%{
  assistant_id: "asst_...",
  created_at: 1699472933,
  id: "file-...",
  object: "assistant.file"
}}
```
See: https://platform.openai.com/docs/api-reference/assistants/createAssistantFile

### assistant_file_delete(assistant_id, file_id)
Detaches a file from the assistant. The file itself is not automatically deleted.

#### Example request
```elixir
OpenAI.assistant_file_delete("asst_...", "file-...")
```

#### Example response
```elixir
{:ok,
%{
  deleted: true,
  id: "file-...",
  object: "assistant.file.deleted"
}}
```
See: https://platform.openai.com/docs/api-reference/assistants/deleteAssistantFile

### threads()
Retrieves the list of threads. 
**NOTE:** At the time of this writing this functionality remains undocumented by OpenAI.

#### Example request
```elixir
OpenAI.threads()
```

#### Example response
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

### threads(params)
Retrieves the list of threads by query params. 
**NOTE:** At the time of this writing this functionality remains undocumented by OpenAI.

#### Example request
```elixir
OpenAI.threads(limit: 2)
```

#### Example response
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

### threads_create(params)
Creates a new thread with some messages and metadata.

#### Example request
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

#### Example response
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

### threads_create_and_run(params)
Creates a new thread and runs it.

#### Example request
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

#### Example response
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

### threads_modify(thread_id, params)
Modifies an existing thread.

#### Example request
```elixir
metadata = %{
  key_3: "value 3"
}

OpenAI.threads_modify("thread_...", metadata: metadata)
```

#### Example response
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

### threads_delete(thread_id)
Modifies an existing thread.

#### Example request
```elixir
OpenAI.threads_delete("thread_...")
```

#### Example response
```elixir
{:ok,
%{
  deleted: true,
  id: "thread_...",
  object: "thread.deleted"
}}
```
See: https://platform.openai.com/docs/api-reference/threads/deleteThread

### thread_messages(thread_id)
Retrieves the list of messages associated with a particular thread.

#### Example request
```elixir
OpenAI.thread_messages("thread_...")
```

#### Example response
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
See: https://platform.openai.com/docs/api-reference/messages/listMessages

### thread_messages(thread_id, params)
Retrieves the list of messages associated with a particular thread, filtered by query params.

#### Example request
```elixir
OpenAI.thread_messages("thread_...", after: "msg_...")
```

#### Example response
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
See: https://platform.openai.com/docs/api-reference/messages/listMessages

### thread_message(thread_id, message_id)
Retrieves a thread message by its id.

#### Example request
```elixir
OpenAI.thread_message("thread_...", "msg_...")
```

#### Example response
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
See: https://platform.openai.com/docs/api-reference/messages/getMessage

### create_thread_message(thread_id, params)
Creates a message within a thread.

#### Example request
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

#### Example response
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


### thread_message_modify(thread_id, message_id, params)
Creates a message within a thread.

#### Example request
```elixir
params = [
  metadata: %{
    key_3: "value 3"
  }
]

OpenAI.thread_message_modify("thread_...", "msg_...", params)
```

#### Example response
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

### thread_message_files(thread_id, message_id)
Retrieves the list of files associated with a particular message of a thread.

#### Example request
```elixir
OpenAI.thread_message_files("thread_...", "msg_...")
```

#### Example response
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
See: https://platform.openai.com/docs/api-reference/messages/listMessageFiles

### thread_message_files(thread_id, message_id, params)
 Retrieves the list of files associated with a particular message of a thread, filtered by query params.

#### Example request
```elixir
OpenAI.thread_message_files("thread_...", "msg_...", after: "file-...")
```

#### Example response
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
See: https://platform.openai.com/docs/api-reference/messages/listMessageFiles

### thread_message_file(thread_id, message_id, file_id)
Retrieves the message file object.

#### Example request
```elixir
OpenAI.thread_message_file("thread_...", "msg_...", "file-...")
```

#### Example response
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

### thread_runs(thread_id, params)
Retrieves the list of runs associated with a particular thread, filtered by query params.

#### Example request
```elixir
OpenAI.thread_runs("thread_...", limit: 10)
```

#### Example response
```elixir
{:ok, %{
  data: [],
  first_id: nil,
  has_more: false,
  last_id: nil,
  object: "list"
}}
```
See: https://platform.openai.com/docs/api-reference/runs/listRuns

### thread_run(thread_id, run_id)
Retrieves a particular thread run by its id.

#### Example request
```elixir
OpenAI.thread_run("thread_...", "run_...")
```

#### Example response
```elixir
{:ok,
 %{
   assistant_id: "asst_J",
   cancelled_at: nil,
   completed_at: 1700234149,
   created_at: 1700234128,
   expires_at: nil,
   failed_at: nil,
   file_ids: [],
   id: "run_",
   instructions: "You are an AI learning assistant.",
   last_error: nil,
   metadata: %{"key_3" => "value 3"},
   model: "gpt-4-1106-preview",
   object: "thread.run",
   started_at: 1700234129,
   status: "expired",
   thread_id: "thread_",
   tools: [%{"type" => "retrieval"}]
 }}
```
See: https://platform.openai.com/docs/api-reference/runs/getRun

### thread_run_create(thread_id, params)
Creates a run for a thread using a particular assistant.

#### Example request
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

#### Example response
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


### thread_run_modify(thread_id, run_id, params)
Modifies an existing thread run.

#### Example request
```elixir
params = [
  metadata: %{
    key_3: "value 3"
  }
]
OpenAI.thread_run_modify("thread_...", "run_...", params)
```

#### Example response
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


### thread_run_cancel(thread_id, run_id)
Cancels an `in_progress` run.

#### Example request
```elixir
OpenAI.thread_run_cancel("thread_...", "run_...")
```

#### Example response
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
See: https://platform.openai.com/docs/api-reference/runs/cancelRun

### thread_run_steps(thread_id, run_id)
Retrieves the list of steps associated with a particular run of a thread.

#### Example request
```elixir
OpenAI.thread_run_steps("thread_...", "run_...")
```

#### Example response
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


### thread_run_steps(thread_id, run_id, params)
  Retrieves the list of steps associated with a particular run of a thread,
  filtered by query params.

#### Example request
```elixir
OpenAI.thread_run_steps("thread_...", "run_...", order: "asc")
```

#### Example response
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

### thread_run_steps(thread_id, run_id, params)
Retrieves the list of steps associated with a particular run of a thread,
  filtered by query params.

#### Example request
```elixir
OpenAI.thread_run_steps("thread_...", "run_...", order: "asc")
```

#### Example response
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

### thread_run_step(thread_id, run_id, step_id)
Retrieves a thread run step by its id.

#### Example request
```elixir
OpenAI.thread_run_step("thread_...", "run_...", "step_...")
```

#### Example response
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

## Deprecated APIs
The following APIs are deprecated, but currently supported by the library for retrocompatibility with older versions. If you are using the following APIs consider to remove it ASAP from your project!

Note: from version 0.5.0 search, answers, classifications API are not supported (since they has been removed by OpenAI), if you still need them consider to use [v0.4.2](https://hex.pm/packages/openai/0.4.2)

### engines() (DEPRECATED: use models instead)
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

#### Example response
```elixir
{:ok, %{
    "id" => "davinci",
    "object" => "engine",
    "max_replicas": ...
  }
}
```
See: https://beta.openai.com/docs/api-reference/engines/retrieve

## License
The package is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
