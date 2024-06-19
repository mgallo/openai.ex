defmodule OpenAI.Stream do
  @moduledoc false

  def new(start_fun) do
    Stream.resource(
      start_fun,
      fn
        {:error, %HTTPoison.Error{} = error} ->
          {
            [
              %{
                "status" => :error,
                "reason" => error.reason
              }
            ],
            error
          }

        %HTTPoison.Error{} = error ->
          {:halt, error}

        res ->
          {res, id} =
            case res do
              {:ok, res = %HTTPoison.AsyncResponse{id: id}} -> {res, id}
              res = %HTTPoison.AsyncResponse{id: id} -> {res, id}
            end

          receive do
            %HTTPoison.AsyncStatus{id: ^id, code: code} ->
              HTTPoison.stream_next(res)

              case code do
                200 ->
                  {[], res}

                _ ->
                  {
                    [
                      %{
                        "status" => :error,
                        "code" => code,
                        "choices" => []
                      }
                    ],
                    res
                  }
              end

            %HTTPoison.AsyncHeaders{id: ^id, headers: _headers} ->
              HTTPoison.stream_next(res)
              {[], res}

            %HTTPoison.AsyncChunk{chunk: chunk} ->
              data =
                chunk
                |> String.split("\n")
                |> Enum.filter(fn line ->
                  String.starts_with?(line, "data: {")
                end)
                |> Enum.map(fn line ->
                  line
                  |> String.replace_prefix("data: ", "")
                  |> Jason.decode!()
                end)

              HTTPoison.stream_next(res)
              {data, res}

            %HTTPoison.AsyncEnd{} ->
              {:halt, res}
          end
      end,
      fn %{id: id} ->
        id |> :hackney.stop_async()
      end
    )
  end
end
