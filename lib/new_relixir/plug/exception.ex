defmodule NewRelixir.Plug.Exception do
  defmacro __using__(_) do
    quote location: :keep do
      use Plug.ErrorHandler

      if :code.is_loaded(Phoenix) do
        defp handle_errors(_conn, %{reason: %Phoenix.Router.NoRouteError{}}) do
          nil
        end
      end

      if :code.is_loaded(Ecto) do
        defp handle_errors(conn, %{reason: %Ecto.NoResultsError{}}) do
          nil
        end
      end

      defp handle_errors(conn, %{kind: kind, reason: reason} = error) do
        transaction =
          case NewRelixir.CurrentTransaction.get() do
            {:ok, transaction} -> transaction
            {:error, _} -> NewRelixir.CurrentTransaction.set(conn.request_path)
            _ -> nil
          end

        NewRelixir.Transaction.record_error(transaction, {kind, reason})
        super(conn, error)
      end

      defoverridable handle_errors: 2
    end
  end
end
