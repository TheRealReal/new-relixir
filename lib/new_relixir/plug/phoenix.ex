defmodule NewRelixir.Plug.Phoenix do
  @moduledoc """
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
  import Elixir.Phoenix.Controller
  import Elixir.Plug.Conn
  import NewRelixir.Utils

  def init(opts) do
    opts
  end

  def call(conn, _config) do
    if NewRelixir.configured? do
      module = conn |> controller_module |> short_module_name
      action = conn |> action_name |> Atom.to_string
      transaction_name = "/#{module}##{action}"

      conn
      |> put_private(:new_relixir_transaction, NewRelixir.Transaction.start(transaction_name))
      |> register_before_send(fn conn ->
        NewRelixir.Transaction.finish(Map.get(conn.private, :new_relixir_transaction))

        conn
      end)
    else
      conn
    end
  end
end
