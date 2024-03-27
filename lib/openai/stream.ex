defmodule OpenAI.Stream do
  @moduledoc false

  def new(start_fun) do
    start_fun
    |> build_stream()
    |> parse_events()
    |> parse_data()
  end

  defp build_stream(start_fun) do
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
              HTTPoison.stream_next(res)
              {[chunk], res}

            %HTTPoison.AsyncEnd{} ->
              {:halt, res}
          end
      end,
      fn %{id: id} ->
        :hackney.stop_async(id)
      end
    )
  end

  defp parse_events(stream) do
    Stream.transform(stream, "", fn
      chunk, acc when is_binary(chunk) ->
        case String.split(acc <> chunk, "\n\n") do
          [] ->
            {[], ""}

          [tail] ->
            {[], tail}

          [_ | _] = events ->
            {events, [tail]} = Enum.split(events, -1)
            {events, tail}
        end

      data, _acc ->
        {[data], ""}
    end)
  end

  defp parse_data(stream) do
    Stream.transform(stream, nil, fn
      "data: [DONE]", acc ->
        {[], acc}

      "data: " <> data, acc ->
        data = Jason.decode!(data)
        {[data], acc}

      data, acc ->
        {[data], acc}
    end)
  end
end
