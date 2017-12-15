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

  @behaviour Elixir.Plug

  alias Plug.Conn

  def init(opts), do: opts

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

  defp start_transaction(%Conn{request_path: "/" <> path, method: method}) do
    transaction_name = "#{path}##{method}"
    NewRelixir.Transaction.start(transaction_name)
  end

  defp finish_transaction(conn) do
    transaction = Map.get(conn.private, :new_relixir_transaction)

    NewRelixir.Transaction.finish(transaction)

    conn
  end
end
