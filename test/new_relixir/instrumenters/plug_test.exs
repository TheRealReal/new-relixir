defmodule NewRelixir.Instrumenters.PlugTest do
  use ExUnit.Case
  use Plug.Test

  import TestHelpers.Assertions

  alias NewRelixir.CurrentTransaction

  @moduletag configured: true

  defmodule FakePlugApp do
    use Plug.Router

    plug NewRelixir.Instrumenters.Plug

    plug :match
    plug :dispatch

    get "/hello" do
      conn = fetch_query_params(conn)
      wait = conn.query_params["wait"]
      if wait, do: wait |> String.to_integer |> :timer.sleep
      send_resp(conn, 200, "Hello!")
    end
  end

  setup do
    start_supervised(NewRelixir.Collector)
    :ok
  end

  setup %{configured: configured} do
    previous_setting = Application.get_env(:new_relixir, :active)
    Application.put_env(:new_relixir, :active, configured)
    on_exit fn -> Application.put_env(:new_relixir, :active, previous_setting) end

    :ok
  end

  test "it generates a transaction name based on request method and path" do
    FakePlugApp.call(conn(:get, "/hello"), [])

    assert {:ok, "hello#GET"} == CurrentTransaction.get()
    assert [{"hello#GET", :total}] == get_metric_keys()
  end

  test "it records the elapsed time of the controller action" do
    {elapsed_time, _} = :timer.tc(fn() ->
      FakePlugApp.call(conn(:get, "/hello?wait=42"), [])
    end)

    [recorded_time] = get_metric_by_key({"hello#GET", :total})

    assert_between(recorded_time, 42_000, elapsed_time)
  end

  @tag configured: false
  test "does not record a transaction when New Relic is not configured" do
    FakePlugApp.call(conn(:get, "/hello"), [])

    assert {:error, :not_found} == CurrentTransaction.get()
    assert [] == get_metric_keys()
  end
end
