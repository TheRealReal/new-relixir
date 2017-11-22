defmodule NewRelixir.Poller do
  use GenServer
  require Logger

  @poll_interval Application.get_env(:new_relic, :poll_interval) || 30_000

  ## API

  def start_link(poll_fun, error_cb \\ &default_error_cb/2) do
    GenServer.start_link(__MODULE__, %{poll_fun: poll_fun, error_cb: error_cb})
  end

  ## Callbacks

  def init(state) do
    timer = :erlang.send_after(@poll_interval, self(), :poll)
    {:ok, Map.put(state, :timer, timer)}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def handle_info(:poll, %{poll_fun: poll_fun, error_cb: error_cb, timer: old_timer}) do
    :erlang.cancel_timer(old_timer)
    timer = :erlang.send_after(@poll_interval, self(), :poll)
    {:ok, hostname} = :inet.gethostname()
    try do
      case poll_fun.() do
        {[], []} ->
          :ok
        {metrics, errors, {start_time, end_time}} ->
          metrics = [
            round(start_time / 1000),
            round(end_time / 1000),
            metrics
          ]
          try do
            NewRelixir.Agent.push(hostname, metrics, errors)
          rescue
            error -> error_cb.(:push_failed, error)
          end
      end
    rescue
      error -> error_cb.(:poll_failed, error)
    end

    {:noreply, %{poll_fun: poll_fun, error_cb: error_cb, timer: timer}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  ## Private functions

  defp default_error_cb(:poll_failed, err_msg) do
    Logger.error("NewRelixir.Poller: polling failed: #{inspect err_msg}")
  end
  defp default_error_cb(:push_failed, err_msg) do
    Logger.error("NewRelixir.Poller: push failed: #{inspect err_msg}")
  end

end
