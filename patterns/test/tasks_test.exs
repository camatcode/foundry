defmodule TasksTest do
  use ExUnit.Case

  alias Tasks

  @moduletag :capture_log

  test "tasks" do
    {time, _res} =
      :timer.tc(fn ->
        1..10
        |> Enum.map(fn _ ->
          Task.async(fn ->
            Process.sleep(1_500)
          end)
        end)
        |> Task.await_many()
      end)

    1 = System.convert_time_unit(time, :microsecond, :second)
  end

  test "yield" do
    task =
      Task.async(fn ->
        Process.sleep(1000)
        :done
      end)

    nil = Task.yield(task, 500)
    {:ok, :done} = Task.yield(task, 1000)
  end

  test :async_stream do
    opts = [total_requests: 200, concurrency: 10, url: "https://example.com"]

    average_time =
      1..opts[:total_requests]
      |> Task.async_stream(
        fn _ ->
          start_time = System.monotonic_time()
          Req.get!(opts[:url])
          System.monotonic_time() - start_time
        end,
        max_concurrency: opts[:concurrency]
      )
      |> Enum.reduce(0, fn {:ok, time}, acc ->
        acc + time
      end)
      |> System.convert_time_unit(:native, :second)
      |> Kernel./(opts[:total_requests])

    IO.inspect(average_time)
  end
end
