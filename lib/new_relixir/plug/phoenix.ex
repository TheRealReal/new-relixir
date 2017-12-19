defmodule NewRelixir.Plug.Phoenix do
  @moduledoc """
  WARNING: this module is deprecated.

  A plug that instruments Phoenix controllers and records their response times in New Relic.

  Inside an instrumented controller's actions, `conn` can be used for further instrumentation with
  `NewRelixir.Plug.Instrumentation` and `NewRelixir.Plug.Repo`.

  ```
  defmodule MyApp.UsersController do
    use Phoenix.Controller
    plug NewRelixir.Plug.Phoenix

    def index(conn, _params) do
      # `conn` is setup for instrumentation
    end
  end
  ```
  """

  @behaviour Plug

  alias NewRelixir.{CurrentTransaction, Transaction, Utils}
  alias Plug.Conn

  def init(opts) do
    IO.warn """
      `NewRelixir.Plug.Phoenix` is deprecated; use `NewRelixir.Instrumenters.Phoenix`
      instead. For Plug-based non-Phoenix projects, use `NewRelixir.Instrumenters.Plug`.
    """, []

    opts
  end

  def call(conn, _config) do
    if NewRelixir.active? do
      record_transaction(conn)
    else
      conn
    end
  end

  defp record_transaction(conn) do
    transaction = Utils.transaction_name(conn)
    CurrentTransaction.set(transaction)

    start = System.monotonic_time()

    Conn.register_before_send(conn, fn conn ->
      stop = System.monotonic_time()
      elapsed_microseconds = System.convert_time_unit(stop - start, :native, :microsecond)

      Transaction.record_web(transaction, elapsed_microseconds)

      conn
    end)
  end
end
