defmodule ErlangAtomicsCounterTest do
  use ExUnit.Case

  alias ErlangAtomicsCounter

  @moduletag :capture_log

  test "atomics" do
    # !! Mutable !!
    existing_user_index = 1
    new_user_index = 2

    my_atomic = :atomics.new(2, signed: false)

    1..100_000
    |> Task.async_stream(
      fn _ ->
        Enum.random([:existing_user, :new_user])
        |> case do
          :existing_user -> :atomics.add(my_atomic, existing_user_index, 1)
          :new_user -> :atomics.add(my_atomic, new_user_index, 1)
        end
      end,
      max_concurrency: 500
    )
    |> Stream.run()

    :atomics.get(my_atomic, existing_user_index) |> IO.inspect(label: :existing)

    :atomics.get(my_atomic, new_user_index) |> IO.inspect(label: :new)
  end

  test "counters" do
    # !! Mutable !!
    existing_user_index = 1
    new_user_index = 2

    my_counter = :counters.new(2, [:write_concurrency])

    1..100_000
    |> Task.async_stream(
      fn _ ->
        Enum.random([:existing_user, :new_user])
        |> case do
          :existing_user -> :counters.add(my_counter, existing_user_index, 1)
          :new_user -> :counters.add(my_counter, new_user_index, 1)
        end
      end,
      max_concurrency: 500
    )
    |> Stream.run()

    :counters.get(my_counter, existing_user_index) |> IO.inspect(label: :existing)

    :counters.get(my_counter, new_user_index) |> IO.inspect(label: :new)
  end
end
