defmodule StreamsTest do
  use ExUnit.Case

  alias Streams

  @moduletag :capture_log

  test "stress_test" do
    {e_time, _} = enum_time(50)
    {s_time, _} = stream_time(50)

    _may_outperform = s_time < e_time

    {e_time, _} = enum_time(5_000)
    {s_time, _} = stream_time(5_000)

    _may_outperform = s_time < e_time

    {e_time, _} = enum_time(500_000)
    {s_time, _} = stream_time(500_000)

    assert s_time < e_time
  end

  test "inf streams" do
    search_term = "programming"
    limit = 3
    starting_item = 31_324_400

    results =
      Stream.resource(
        fn -> starting_item end,
        fn item ->
          # returns {[data], next_item_to_explore}
          do_work(item, search_term)
        end,
        fn _ -> nil end
      )
      |> Enum.take(limit)

    assert Enum.count(results) == limit
  end

  test "parse large CSV" do
  end

  defp do_work(item, search_term) do
    "https://hacker-news.firebaseio.com/v0/item/#{item}.json"
    |> Req.get!()
    |> Map.get(:body)
    |> case do
      %{"type" => "comment", "text" => text} = data ->
        (text || "")
        |> String.downcase()
        |> String.contains?(search_term)
        |> case do
          true -> {[data], item + 1}
          _ -> do_work(item + 1, search_term)
        end

      _ ->
        do_work(item + 1, search_term)
    end
  end

  defp enum_time(upper_bound) do
    :timer.tc(fn ->
      1..upper_bound
      |> Enum.reject(&(rem(&1, 2) == 1))
      |> Enum.map(&(&1 * 2))
      |> Enum.sum()
    end)
  end

  defp stream_time(upper_bound) do
    :timer.tc(fn ->
      1..upper_bound
      |> Stream.reject(&(rem(&1, 2) == 1))
      |> Stream.map(&(&1 * 2))
      |> Enum.sum()
    end)
  end
end
