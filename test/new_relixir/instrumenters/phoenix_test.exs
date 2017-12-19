defmodule NewRelixir.Instrumenters.PhoenixTest do
  use ExUnit.Case

  import TestHelpers.Assertions

  alias NewRelixir.CurrentTransaction
  alias NewRelixir.Instrumenters.Phoenix
  alias Plug.Conn

  @moduletag configured: true

  setup %{configured: configured} do
    previous_setting = Application.get_env(:new_relixir, :active)
    Application.put_env(:new_relixir, :active, configured)
    on_exit fn -> Application.put_env(:new_relixir, :active, previous_setting) end

    :ok
  end

  test "it generates a transaction name based on controller and action names" do
    conn =
      %Conn{}
      |> Conn.put_private(:phoenix_controller, SomeApplication.FakeController)
      |> Conn.put_private(:phoenix_action, :test_action)

    transaction = Phoenix.phoenix_controller_call(:start, %{}, %{conn: conn})

    assert "FakeController#test_action" == transaction
    assert {:ok, "FakeController#test_action"} == CurrentTransaction.get()
  end

  test "it records the elapsed time of the controller action in microseconds" do
    :ok = Phoenix.phoenix_controller_call(:stop, 42_000_000, "SomeController#some_action")

    [recorded_time] = get_metric_by_key({"SomeController#some_action", :total})

    assert 42_000 == recorded_time
  end

  @tag configured: false
  test "does not record a transaction when New Relic is not configured" do
    nil = Phoenix.phoenix_controller_call(:stop, 42_000_000, "Controller#action")

    assert {:error, :not_found} == CurrentTransaction.get()
    assert [] == get_metric_keys()
  end
end
