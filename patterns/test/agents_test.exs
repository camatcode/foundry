defmodule AgentsTest do
  use ExUnit.Case

  alias Agents

  @moduletag :capture_log

  test "agents" do
    state = []
    {:ok, pid} = Agent.start(fn -> state end)
    true = Process.alive?(pid)
    ^state = Agent.get(pid, fn state -> state end)

    :ok =
      1..10
      |> Enum.each(fn value ->
        Agent.update(pid, fn state -> [value | state] end)
      end)

    [10, 9, 8, 7, 6, 5, 4, 3, 2, 1] =
      Agent.get(pid, fn state -> state end)

    :ok = Agent.stop(pid)

    false = Process.alive?(pid)
  end

  defmodule CoolStack do
    use Agent

    def start(state \\ []) do
      Agent.start(fn -> state end, name: CoolStack)
    end

    def stop do
      Agent.stop(CoolStack)
    end

    def push(element) do
      Agent.update(CoolStack, fn state -> [element | state] end)
    end

    def inspect do
      Agent.get(CoolStack, fn state -> state end)
    end

    def pop do
      Agent.get_and_update(
        CoolStack,
        fn
          [] -> {{:error, :empty}, []}
          [head | rest] -> {head, rest}
        end
      )
    end
  end

  test "stack" do
    {:ok, pid} = CoolStack.start()
    ^pid = CoolStack |> Process.whereis()

    :waiting = Process.info(pid)[:status]

    :ok =
      1..10
      |> Enum.each(&CoolStack.push(&1))

    [10, 9, 8, 7, 6, 5, 4, 3, 2, 1] =
      :sys.get_state(CoolStack)

    10 = CoolStack.pop()
    9 = CoolStack.pop()

    [8, 7, 6, 5, 4, 3, 2, 1] =
      :sys.get_state(CoolStack)

    :ok = CoolStack.stop()
  end
end
