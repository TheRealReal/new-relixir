defmodule NewRelixir.CollectorTest do
  use ExUnit.Case, async: true

  import TestHelpers.Assertions

  alias NewRelixir.Collector

  describe "start_link/0" do
    test "function defined" do
      assert_defined_function(Collector, :start_link, 0)
    end
  end

  describe "start_link/1" do
    test "function defined" do
      assert_defined_function(Collector, :start_link, 1)
    end
  end
end
