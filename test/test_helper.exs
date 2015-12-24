defmodule TestHelpers.Assertions do
  import ExUnit.Assertions

  def assert_contains(collection, value) do
    assert Enum.member?(collection, value), "expected #{inspect(collection)} to contain #{inspect(value)}"
  end

  def assert_between(actual, lower_bound, upper_bound) do
    assert actual >= lower_bound && actual <= upper_bound, "expected #{inspect(actual)} to be between #{inspect(lower_bound)} and #{inspect(upper_bound)}"
  end
end

ExUnit.start()
