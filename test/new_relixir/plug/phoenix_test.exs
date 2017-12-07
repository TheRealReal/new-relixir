defmodule NewRelixir.Plug.PhoenixTest do
  use ExUnit.Case, async: false
  import TestHelpers.Assertions

  import Plug.Conn

  @moduletag configured: true

  setup %{configured: configured} do
    previous_setting = Application.get_env(:new_relixir, :active)
    Application.put_env(:new_relixir, :active, configured)
    on_exit fn -> Application.put_env(:new_relixir, :active, previous_setting) end

    conn = %Plug.Conn{}
    |> put_private(:phoenix_controller, SomeApplication.FakeController)
    |> put_private(:phoenix_action, :test_action)

    {:ok, conn: conn}
  end

  test "it assigns a transaction to the connection", %{conn: conn} do
    conn = NewRelixir.Plug.Phoenix.call(conn, nil)
    assert_is_struct(conn.private[:new_relixir_transaction], NewRelixir.Transaction)
  end

  test "it generates a transaction name based on controller and action names", %{conn: conn} do
    conn = NewRelixir.Plug.Phoenix.call(conn, nil)
    assert conn.private[:new_relixir_transaction].name == "FakeController#test_action"
  end

  test "it records the elapsed time of the controller action", %{conn: conn} do
    {_, elapsed_time} = :timer.tc(fn() ->
      conn = NewRelixir.Plug.Phoenix.call(conn, nil)
      :ok = :timer.sleep(42)
      Enum.each(conn.before_send, fn (f) -> f.(conn) end)
    end)

    [recorded_time] = get_metric_by_key({"FakeController#test_action", :total})

    assert_between(recorded_time, 42000, elapsed_time)
  end

  @tag configured: false
  test "if New Relic is not configured, it does not modify connection", %{conn: conn} do
    assert NewRelixir.Plug.Phoenix.call(conn, nil) == conn
  end
end
