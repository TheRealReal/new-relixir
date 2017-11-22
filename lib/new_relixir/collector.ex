defmodule NewRelixir.Collector do
  use GenServer
  @name __MODULE__
  @default_state [%{}, %{}]

  def start_link(_opts \\ []) do
    GenServer.start_link(@name, @default_state, name: @name)
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

  def handle_cast({:record_value, key, time}, [metrics, errors]) do
    metrics = Map.update(metrics, key, [time], &([time | &1]))
    {:noreply, [metrics, errors]}
  end

  def handle_cast({:record_error, key}, [metrics, errors]) do
    errors = Map.update(errors, key, 1, &(1 + &1))
    {:noreply, [metrics, errors]}
  end

  def handle_call(:poll, _from, state) do
    {:reply, state, @default_state}
  end
end
