defmodule NewRelixir.UtilsTest do
  use ExUnit.Case, async: true

  alias NewRelixir.Utils

  describe "transaction_name/1" do
    test "uses controller and action name when in Phoenix" do
      phoenix_conn = %Plug.Conn{
        private: %{
          phoenix_action: :index,
          phoenix_controller: MyApp.ThingsController
        }
      }

      assert Utils.transaction_name(phoenix_conn) == "ThingsController#index"
    end

    test "uses request path and method name when in bare Plug" do
      plug_conn = %Plug.Conn{
        request_path: "/the/full/path",
        method: "GET"
      }

      assert Utils.transaction_name(plug_conn) == "the/full/path#GET"
    end

    test "is nil when unable to figure out a transaction name" do
      assert Utils.transaction_name(%Plug.Conn{}) == nil
    end
  end
end
