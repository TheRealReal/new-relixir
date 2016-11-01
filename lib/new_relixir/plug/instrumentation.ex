defmodule NewRelixir.Plug.Instrumentation do
  @moduledoc """
  Utility methods for instrumenting parts of an Elixir app.
  """

  @doc """
  Instruments a database call and records the elapsed time.

  * `conn` should be a `Plug.Conn` that has been configured by `NewRelixir.Plug.Phoenix`.
  * `action` is the name of the repository method being instrumented.
  * `queryable` is the `Queryable` being passed to the repository.

  By default, the query name will be infered from `queryable` and `action`. This can be overriden
  by providing a `:query` option in `opts`.
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
    model_name(model_type)
  end
  # Ecto 1.1 clause
  defp infer_model(%{model: model}) do
    infer_model(model)
  end
  # Ecto 2.0 clause
  defp infer_model(%{data: data}) do
    infer_model(data)
  end

  defp infer_model(%Ecto.Query{from: {_, model_type}}) do
    model_name(model_type)
  end

  defp infer_model(%Ecto.Query{}) do
    nil
  end

  defp infer_model(queryable) do
    infer_model(Ecto.Queryable.to_query(queryable))
  end

  defp model_name(model_type) do
    model_type |> Module.split |> List.last
  end

  defp record(opts, elapsed) do
    if (conn = Keyword.get(opts, :conn)) && (transaction = Map.get(conn.private, :new_relixir_transaction)) do
      NewRelixir.Transaction.record_db(transaction, get_query(opts), elapsed)
    end
  end

  defp get_query(opts) do
    case Keyword.fetch(opts, :query) do
      {:ok, value} ->
        value

      :error ->
        case {Keyword.fetch(opts, :model), Keyword.fetch(opts, :action)} do
          {{:ok, model}, {:ok, action}} ->
            {model, action}

          _ ->
            "SQL"
        end
    end
  end
end
