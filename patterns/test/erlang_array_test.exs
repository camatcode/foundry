defmodule ErlangArrayTest do
  use ExUnit.Case

  @moduletag :capture_log

  test "array" do
    arr =
      :array.new()
      |> then(&:array.set(0, "Alex Koutmos", &1))
      |> then(&:array.set(1, "Bob Smith", &1))
      |> then(&:array.set(2, "Jannet Angelo", &1))

    "Bob Smith" = arr.get(1, arr)
    "Jannet Angelo" = arr.get(2, arr)
  end
end
