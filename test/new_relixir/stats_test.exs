defmodule NewRelixir.StatsTest do
  use ExUnit.Case, async: true

  alias NewRelixir.Stats

  describe "#transform_aggregated_metrics" do
    import Stats, only: [transform_aggregated_metrics: 3]

    test "returns empty data set" do
      assert transform_aggregated_metrics(%{}, %{}, 100) == {[], [], 100}
    end

    test "returns web summary" do
      metrics = %{{"home/index", :total} => [1000, 2000, 1000, 3000]}

      {summary, _, _} = transform_aggregated_metrics(metrics, %{}, 200)

      http_summary = Enum.find_value(summary, fn [metric | values] ->
        if(metric.name == "HttpDispatcher", do: values)
      end)
      assert http_summary == [[4, 0.007, 0.007, 0.0, 0.003, 0.015]]
    end

    test "returns error summary" do
      errors = %{
        {"home/index", "FunctionClauseError", "no function clause matching"} => 2
      }

      {_, summary, _} = transform_aggregated_metrics(%{}, errors, 200)
      [sample | _] = summary
      [_, scope, message, error, details] = sample

      assert Enum.count(summary) == 2

      assert scope == "WebTransaction/Uri/home/index"
      assert message == "no function clause matching"
      assert error == "FunctionClauseError"
      assert details == %{
        parameter_groups: %{},
        request_params: %{},
        request_uri: "home/index",
        stack_trace: []
      }
    end
  end
end
