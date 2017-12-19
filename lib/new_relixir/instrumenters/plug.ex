defmodule NewRelixir.Instrumenters.Plug do
  @moduledoc """
  New Relic instrumenter for raw Plug endpoints.

  Transaction records are composed of the current request path and method, e.g.
  `/path/to/my-page#GET`, `/path/to/update#POST`.

  To start recording, add `plug NewRelixir.Instrumenters.Plug` at the beginning of
  your pipeline:

  ```
  defmodule MyApp.PlugRouter do
    use Plug.Router

    plug NewRelixir.Instrumenters.Plug

    plug :match
    plug :dispatch

    get "/hello" do
      send_resp(conn, 200, "Hello!")
    end
  end
  ```
  """

  @behaviour Plug

  alias NewRelixir.{CurrentTransaction, Transaction}
  alias Plug.Conn

  def init(opts), do: opts

  def call(conn, _config) do
    if NewRelixir.active? do
      record_transaction(conn)
    else
      conn
    end
  end

  defp record_transaction(%Conn{request_path: "/" <> path, method: method} = conn) do
    transaction = "#{path}##{method}"
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
