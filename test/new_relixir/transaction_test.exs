defmodule NewRelixir.TransactionTest do
  use ExUnit.Case, async: false
  import TestHelpers.Assertions

  alias NewRelixir.Transaction

  @name "Test Transaction"

  # finish

  test "finish records elapsed time with correct key" do
    transaction = Transaction.start(@name)
    Transaction.finish(transaction)

    assert_contains(get_metric_keys(), {@name, :total})
  end

  test "finish records accurate elapsed time" do
    {_, elapsed_time} = :timer.tc(fn() ->
      transaction = Transaction.start(@name)
      :ok = :timer.sleep(42)
      Transaction.finish(transaction)
    end)

    [recorded_time] = get_metric_by_key({@name, :total})

    assert_between(recorded_time, 42000, elapsed_time)
  end

  # record_db

  @model "SomeModel"
  @action "get"
  @elapsed 42

  test "record_db records query time with correct key when given model and action tuple" do
    transaction = Transaction.start(@name)
    Transaction.record_db(transaction, {@model, @action}, @elapsed)

    assert_contains(get_metric_keys(), {@name, {:db, "#{@model}.#{@action}"}})
  end

  test "record_db records accurate query time when given model and action tuple" do
    transaction = Transaction.start(@name)
    Transaction.record_db(transaction, {@model, @action}, @elapsed)

    [recorded_time] = get_metric_by_key({@name, {:db, "#{@model}.#{@action}"}})

    assert recorded_time == @elapsed
  end

  @query "FooBar"

  test "record_db records query time with correct key when given a string" do
    transaction = Transaction.start(@name)
    Transaction.record_db(transaction, @query, @elapsed)

    assert_contains(get_metric_keys(), {@name, {:db, @query}})
  end

  test "record_db records accurate query time when given a string" do
    transaction = Transaction.start(@name)
    Transaction.record_db(transaction, @query, @elapsed)

    [recorded_time] = get_metric_by_key({@name, {:db, @query}})

    assert recorded_time == @elapsed
  end
end
