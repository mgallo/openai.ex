defmodule OpenAI.SSEStreamParser do
  @moduledoc false

  @line_endings ["\r\n", "\r", "\n"]

  def parse(stream) do
    stream
    |> parse_lines()
    |> parse_events()
  end

  defp parse_lines(stream) do
    Stream.transform(
      stream,
      fn -> "" end,
      fn
        # HTTP 200 is well formed text/event-stream
        # https://html.spec.whatwg.org/multipage/server-sent-events.html#event-stream-interpretation
        {200, chunk}, acc when is_binary(chunk) ->
          case String.split(acc <> chunk, @line_endings) do
            [] ->
              {[], ""}

            [tail] ->
              {[], tail}

            [_ | _] = events ->
              {events, [tail]} = Enum.split(events, -1)
              {events, tail}
          end

        # Any other HTTP code we just emit since we can't depend
        # on content-type with OpenAI
        {code, chunk}, acc when is_integer(code) ->
          {[], acc <> chunk}

        {:error, error}, acc ->
          {[error], acc}
      end,
      fn acc -> {[acc], nil} end,
      fn _acc -> :ok end
    )
  end

  defp parse_events(stream) do
    Stream.transform(
      stream,
      fn -> {"", nil, nil} end,
      fn
        # If the line is blank, emit the event
        "", {event, _type, _id} ->
          {[event], {"", nil, nil}}

        # If the line starts with a U+003A (:), ignore the line
        ":" <> _, acc ->
          {[], acc}

        # Process the field
        line, acc when is_binary(line) ->
          {[], parse_line(line, acc)}

        # Pass other data through
        data, _acc ->
          {[data], {"", nil, nil}}
      end,
      fn {data, _type, _id} ->
        {[data], nil}
      end,
      fn _acc -> :ok end
    )
  end

  defp parse_line(line, {event, type, id} = acc) do
    case String.split(line, [": ", ":"], parts: 2) do
      ["event", type] ->
        {event, type, id}

      ["id", id] ->
        {event, type, id}

      ["data", value] ->
        {event <> value, type, id}

      # Not implemented
      ["retry", _value] ->
        acc

      # Because OpenAI emits malformed responses, we need to collect spurious
      # content here as an event to be processed downstream
      data ->
        {Enum.join(data, ":"), type, id}
    end
  end
end
