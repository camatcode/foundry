defmodule ErlangQueueTest do
  use ExUnit.Case

  @moduletag :capture_log

  # doctest ErlangQueue

  test "queues" do
    # WARNING: many queue ops require O(n) operations
    # If using queues, wrap them in a struct or a map and to avoid O(n) 
    # complexity when necessary
    my_queue = :queue.new()

    my_queue = :queue.in(1, my_queue)
    my_queue = :queue.in(2, my_queue)

    {{:value, my_value}, my_queue} = :queue.out(my_queue)
    assert my_value == 1
    {{:value, my_value}, my_queue} = :queue.out(my_queue)
    assert my_value == 2
    {:empty, _my_queue} = :queue.out(my_queue)
  end
end
