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

  @behaviour Elixir.Plug

  alias NewRelixir.Utils
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
    transaction = start_transaction(conn)

    conn
    |> Conn.put_private(:new_relixir_transaction, transaction)
    |> Conn.register_before_send(&finish_transaction/1)
  end

  defp start_transaction(conn) do
    NewRelixir.Transaction.start(Utils.transaction_name(conn))
  end

  defp finish_transaction(conn) do
    transaction = Map.get(conn.private, :new_relixir_transaction)

    NewRelixir.Transaction.finish(transaction)

    conn
  end
end
