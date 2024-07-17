defmodule OpenAI.Stream do
  @moduledoc false

  alias OpenAI.SSEStreamParser

  def new(start_fun) do
    start_fun
    |> build_stream()
    |> SSEStreamParser.parse()
    |> decode_data()
  end

  defp build_stream(start_fun) do
    Stream.resource(
      start_fun,
      fn
        {:ok, res = %HTTPoison.AsyncResponse{}} ->
          {[], {nil, res}}

        {:error, %HTTPoison.Error{} = error} ->
          {[{:error, error}], :error}

        %HTTPoison.Error{} = error ->
          {[{:error, error}], :error}

        {code, res = %HTTPoison.AsyncResponse{id: id}} ->
          receive do
            %HTTPoison.AsyncStatus{id: ^id, code: code} ->
              HTTPoison.stream_next(res)
              {[], {code, res}}

            # We should be able to tell the difference between an error and the
            # event stream with content-type (text/event-stream), but
            # unfortunately OpenAI doesn't obey the spec.
            %HTTPoison.AsyncHeaders{id: ^id, headers: _headers} ->
              HTTPoison.stream_next(res)
              {[], {code, res}}

            %HTTPoison.AsyncChunk{chunk: chunk} ->
              HTTPoison.stream_next(res)
              {[{code, chunk}], {code, res}}

            %HTTPoison.AsyncEnd{id: ^id} ->
              {:halt, {code, res}}
          end

        :error ->
          {:halt, :error}
      end,
      fn
        {_code, %{id: id}} ->
          :hackney.stop_async(id)

        :error ->
          :ok
      end
    )
  end

  defp decode_data(stream) do
    stream
    |> Stream.reject(fn
      "[DONE]" -> true
      "" -> true
      _ -> false
    end)
    |> Stream.map(fn
      data when is_binary(data) ->
        case Jason.decode(data) do
          {:ok, struct} ->
            struct

          {:error, _reason} ->
            data
        end

      %HTTPoison.Error{} = error ->
        %{"reason" => error.reason, "status" => :error}

      data ->
        data
    end)
  end
end
