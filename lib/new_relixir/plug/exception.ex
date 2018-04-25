defmodule NewRelixir.Plug.Exception do
  defmacro __using__(env) do
    quote location: :keep do
      use Plug.ErrorHandler

      # Ignore 404s for Plug routes
      defp handle_errors(conn, %{reason: %FunctionClauseError{function: :do_match}}) do
        nil
      end

      if :code.is_loaded(Phoenix) do
        # Ignore 404s for Phoenix routes
        defp handle_errors(conn, %{reason: %Phoenix.Router.NoRouteError{}}) do
          nil
        end
      end

      defp handle_errors(conn, %{kind: kind, reason: reason}) do
        transaction =
          case NewRelixir.CurrentTransaction.get() do
            {:ok, transaction} -> transaction
            {:error, _} -> NewRelixir.CurrentTransaction.set(conn.request_path)
            _ -> nil
          end

        NewRelixir.Transaction.notice_error(transaction, {kind, reason})
      end

      defoverridable handle_errors: 2
    end
  end
end
