defmodule GenQueueTest do
  use ExUnit.Case

  @moduletag :capture_log

  doctest GenQueue

  setup %{module: module, test: test} do
    queue_name = Module.concat([module, test, GenQueue])
    child_spec = %{id: GenQueue, restart: :transient, start: {GenQueue, :start_link, [[], queue_name]}}
    {:ok, queue_pid} = start_supervised(child_spec)
    %{queue_pid: queue_pid, queue_name: queue_name}
  end
  #pg 131

  test "queue test", %{queue_name: qname} do
    GenQueue.push(qname, 1)
    GenQueue.push(qname, 2)

    assert 1 == GenQueue.pop(qname)

    refute Process.whereis(GenQueue)
  end

  test "genqueue" do
    {:ok, _pid} = GenQueue.start_link([1, 2, 3])
    3 = GenQueue.len()

    results = Enum.map(4..6, &GenQueue.push(&1))

    Enum.each(results, fn r -> assert r == :ok end)
    6 = GenQueue.len()

    1 = GenQueue.pop()

    5 = GenQueue.len()

    :ok = GenServer.stop(GenQueue)
  end
end
