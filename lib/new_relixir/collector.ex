defmodule NewRelixir.Collector do
  use GenServer
  @name __MODULE__
  @default_state [%{}, %{}]

  def start_link(_opts \\ []) do
    GenServer.start_link(@name, [current_time() | @default_state], name: @name)
  end

  def record_value({name, data}, elapsed) do
    GenServer.cast(@name, {:record_value, {name, data}, elapsed})
  end

  def record_error(transaction_name, {type, message}) do
    GenServer.cast(@name, {:record_error, {transaction_name, type, message}})
  end

  def poll do
    GenServer.call(@name, :poll)
  end

  def handle_cast({:record_value, key, time}, [start_time, metrics, errors]) do
    metrics = Map.update(metrics, key, [time], &([time | &1]))
    {:noreply, [start_time, metrics, errors]}
  end

  def handle_cast({:record_error, key}, [start_time, metrics, errors]) do
    errors = Map.update(errors, key, 1, &(1 + &1))
    {:noreply, [start_time, metrics, errors]}
  end

  def handle_call(:poll, _from, state) do
    current_time = current_time()
    {:reply, [current_time | state], [current_time | @default_state]}
  end

  defp current_time do
    :os.system_time(:milli_seconds)
  end
end
