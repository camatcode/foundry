defmodule GenQueue do
  @moduledoc false
  use GenServer, restart: :transient

  # --- Client ---
  def start_link(start_elems, name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, start_elems, name: name)
  end

  def len(instance \\ __MODULE__) do
    GenServer.call(instance, :len)
  end

  def push(instance \\ __MODULE__, element) do
    GenServer.cast(instance, {:push, element})
  end

  def pop(instance \\ __MODULE__) do
    GenServer.call(instance, :pop)
  end

  # --- Server ----
  @impl GenServer
  def init(start_elems) do
    state = %{
      queue: :queue.from_list(start_elems),
      len: length(start_elems)
    }

    {:ok, state}
  end

  @impl GenServer
  def handle_call(:len, _from, %{len: leng} = state) do
    {:reply, leng, state}
  end

  def handle_call(:pop, _from, %{queue: queue, len: leng}) do
    {queue, leng, element} =
      case :queue.out(queue) do
        {:empty, queue} -> {queue, 0, :empty}
        {{:value, value}, queue} -> {queue, leng - 1, value}
      end

    {:reply, element, %{queue: queue, len: leng}}
  end

  @impl GenServer
  def handle_cast({:push, element}, %{queue: queue, len: leng}) do
    queue = :queue.in(element, queue)
    state = %{queue: queue, len: leng + 1}
    {:noreply, state}
  end
end
