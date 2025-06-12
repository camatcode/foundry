defmodule GenCron do
  @moduledoc false
  use GenServer, restart: :transient

  require Logger

  # --- Client ---
  def start_link(run_interval) do
    GenServer.start_link(__MODULE__, run_interval, name: __MODULE__)
  end

  @impl GenServer
  def handle_continue(:schedule_next_run, run_interval) do
    Process.send_after(self(), :perform_cron_work, run_interval)
    {:noreply, run_interval}
  end

  @impl GenServer
  def handle_info(:perform_cron_work, run_interval) do
    memory_hogs =
      Process.list()
      |> Enum.map(fn pid ->
        {:memory, memory} = Process.info(pid, :memory)
        {pid, memory}
      end)
      |> Enum.sort_by(fn {_, memory} -> memory end, :desc)
      |> Enum.take(3)

    Logger.info("Top 3 memory hogs: #{inspect(memory_hogs)}")

    {:noreply, run_interval, {:continue, :schedule_next_run}}
  end

  @impl GenServer
  def init(run_interval) do
    {:ok, run_interval, {:continue, :schedule_next_run}}
  end
end
