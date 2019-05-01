defmodule NewRelixir.Transaction do
  @moduledoc """
  Records information about an instrumented web transaction.
  """

  alias NewRelixir.Collector

  @doc """
  Send an error to New Relic
  """
  @spec record_error(transaction :: binary, error :: {binary, binary | Exception.t}) :: :ok
  def record_error(transaction, {type, message})
    when is_binary(transaction) do
    Collector.record_error(transaction, {type, message})
  end

  @doc """
  Records the total time of a web transaction.
  """
  @spec record_web(transaction :: binary, elapsed_time :: integer) :: :ok
  def record_web(transaction, elapsed_time)
      when is_binary(transaction)
      and is_integer(elapsed_time) do
    Collector.record_value({transaction, :total}, elapsed_time)
  end

  @doc """
  Records a database query made in a web transaction.
  """
  @spec record_db(transaction :: binary, query :: binary, elapsed_time :: integer) :: :ok
  def record_db(transaction, query, elapsed_time)
      when is_binary(transaction)
      and is_binary(query)
      and is_integer(elapsed_time) do
    Collector.record_value({transaction, {:db, query}}, elapsed_time)
  end

  @doc """
  Records an external HTTP call made in a transaction.
  """
  @spec record_external(transaction :: binary, host :: binary, elapsed_time :: integer) :: :ok
  def record_external(transaction, host, elapsed_time)
      when is_binary(transaction)
      and is_binary(host)
      and is_integer(elapsed_time) do
    Collector.record_value({transaction, {:ext, host}}, elapsed_time)
  end

  def record_external({:background, transaction}, host, elapsed_time)
    when is_binary(host) 
    and is_integer(elapsed_time) do
    Collector.record_value({{:background, transaction}, {:external, host}}, elapsed_time)
  end

  def record_background(transaction, elapsed_time) do
    Collector.record_value({{:background, transaction}, :total}, elapsed_time)
  end
end
