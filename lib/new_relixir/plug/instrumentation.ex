defmodule NewRelixir.Plug.Instrumentation do
  @moduledoc """
  Utility methods for instrumenting parts of an Ecto app.
  """

  import NewRelixir.Utils

  alias NewRelixir.{CurrentTransaction, Transaction}

  @doc """
  Instruments a database call and records the elapsed time.

  * `action` is the name of the operation being instrumented.
  * `sql` is the `SQL Instruction` being passed to the transaction recorder.
  * `params` a list of parameters to be used on the prepared statement.
  * `opts` is a keyword list of overrides to parts of the recorded transaction name.
  * `f` is the function to be instrumented.

  By default, the query name will be inferred from `queryable` and `action`. This
  can be overriden by providing a `:query` option in `opts`.
  """
  @spec instrument_db(atom, String.t(), [term()], Keyword.t(), fun) :: any
  def instrument_db(action, sql, params, opts, f) do
    {elapsed, result} = :timer.tc(f)

    opts
    |> Keyword.put(:query, sql)
    |> record(elapsed)

    result
  end

  @doc """
  Instruments a database call and records the elapsed time.

  * `action` is the name of the repository function being instrumented.
  * `queryable` is the `Queryable` being passed to the repository.
  * `opts` is a keyword list of overrides to parts of the recorded transaction name.
  * `f` is the function to be instrumented.

  By default, the query name will be inferred from `queryable` and `action`. This
  can be overriden by providing a `:query` option in `opts`.
  """
  @spec instrument_db(atom, Ecto.Queryable.t, Keyword.t, fun) :: any
  def instrument_db(action, queryable, opts, f) do
    {elapsed, result} = :timer.tc(f)

    opts
    |> put_model(queryable)
    |> put_action(action)
    |> record(elapsed)

    result
  end

  defp put_model(opts, queryable) do
    case Keyword.fetch(opts, :model) do
      {:ok, _} -> opts
      :error ->
        if model = infer_model(queryable) do
          Keyword.put(opts, :model, model)
        else
          opts
        end
    end
  end

  defp put_action(opts, action) do
    Keyword.put_new(opts, :action, action)
  end

  defp infer_model(%{__struct__: model_type, __meta__: %Ecto.Schema.Metadata{}}) do
    short_module_name(model_type)
  end
  defp infer_model(%{data: data}) do #ecto 2.0
    infer_model(data)
  end

  defp infer_model(%Ecto.Query{from: {_, model_type}}) when not is_nil(model_type) do
    short_module_name(model_type)
  end
  defp infer_model(%Ecto.Query{}) do
    nil
  end
  defp infer_model([first_queryable | _others]) do
    infer_model(first_queryable)
  end
  defp infer_model(queryable) do
    infer_model(Ecto.Queryable.to_query(queryable))
  end

  defp record(opts, elapsed) do
    case CurrentTransaction.get() do
      {:ok, transaction} ->
        query = get_query(opts)
        Transaction.record_db(transaction, query, elapsed)
      error ->
        error
    end
  end

  defp get_query(opts) do
    case Keyword.fetch(opts, :query) do
      {:ok, value} ->
        value

      :error ->
        case {Keyword.fetch(opts, :model), Keyword.fetch(opts, :action)} do
          {{:ok, model}, {:ok, action}} ->
            "#{model}.#{action}"

          _ ->
            "SQL"
        end
    end
  end
end
