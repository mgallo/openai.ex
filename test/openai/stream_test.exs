defmodule OpenAI.StreamTest do
  use ExUnit.Case

  describe "new/1" do
    test "handles error" do
      results =
        OpenAI.Stream.new(fn ->
          HTTPoison.get("http://nxdomain-error/", [], stream_to: self(), async: :once)
        end)
        |> Enum.to_list()

      assert [%{"reason" => :nxdomain, "status" => :error}] == results
    end
  end
end
