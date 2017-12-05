defmodule NewRelixir.Stats do
  def pull do
    [end_time, start_time, metrics, errors] = NewRelixir.Collector.pull
    transform_aggregated_metrics(metrics, errors, {start_time, end_time})
  end

  def transform_aggregated_metrics(metrics, errors, time) when metrics == %{} and errors == %{} do
    {[], [], time}
  end
  def transform_aggregated_metrics(metrics, errors, time) do
    ms = Enum.flat_map(metrics, &transform_histogram/1)
    errs = Enum.flat_map(errors, &transform_error_counter/1)

    {[webtransaction_total(ms), db_total(ms) | errors_total(errs) ++ ms], errs, time}
  end

  def transform_error_counter({{scope, type, message}, count}) do
    error = [
      :os.system_time(:micro_seconds) / 1_000_000,
      scope2bin(scope),
      to_string(message),
      to_string(type),
      [%{
        parameter_groups: %{},
        stack_trace: [],
        request_params: %{},
        request_uri: scope}]
    ]
    List.duplicate(error, count)
  end

  def summary(values) do
    summary(values, {0, 0, 0, 0, 0})
  end
  def summary([], {count, sum, min, max, sum2}) do
    [
      count,
      sum / 1_000_000,
      sum / 1_000_000,
      min / 1_000_000,
      max / 1_000_000,
      sum2 / 1_000_000_000
    ]
  end
  def summary([v|rest], {count, sum, min, max, sum2}) do
    summary(rest, {count+1, sum+v, v < min && v || min, v > max && v || max, sum2+v*v})
  end
  def transform_histogram({key, values}) do
    data = summary(values)

    case key do
      {scope, {:db, segment}} when is_binary(scope) ->
        [
         [%{name: "Database/#{segment}", scope: scope2bin(scope)}, data],
         [%{name: "Database/allWeb", scope: ""}, data],
         [%{name: "Database/all", scope: ""}, data]
        ]

      {scope, {:ext, host}} when is_binary(scope) and is_binary(host) ->
        [
         [%{name: "External/all", scope: ""}, data],
         [%{name: "External/allWeb", scope: ""}, data],
         [%{name: "External/#{host}", scope: ""}, data],
         [%{name: "External/#{host}/all", scope: ""}, data],
         [%{name: "External/#{host}", scope: scope2bin(scope)}, data]
        ]

      {{:background, scope}, :total} when is_binary(scope) ->
          [[%{name: bgscope2bin(scope), scope: ""}, data]]

      {{:background, scope}, {class, segment}} when is_binary(scope) ->
          [[%{name: class2bin(class) <> "/" <> to_string(segment), scope: bgscope2bin(scope)}, data]]

      {scope, {class, segment}} when is_binary(scope) ->
          [[%{name: class2bin(class) <> "/" <> to_string(segment), scope: scope2bin(scope)}, data]]

      {scope, :total} when is_binary(scope) ->
          [[%{name: "WebTransaction/Uri/#{scope}", scope: ""}, data]]

      {a, b} when is_atom(a) and is_atom(b) ->
          [[%{name: "OtherTransaction/#{a}/#{b}", scope: ""}, data]]
      _ ->
          []
    end
  end

  def webtransaction_total(ms) do
    name = "WebTransaction"
    n    = Enum.sum(pluck(name, 0, ms))
    sum  = Enum.sum(pluck(name, 1, ms))
    min  = Enum.min(pluck(name, 3, ms), &zero/0)
    max  = Enum.max(pluck(name, 4, ms), &zero/0)
    sum2 = Enum.sum(pluck(name, 5, ms))

    [%{name: "HttpDispatcher", scope: ""}, [n, sum, sum, min, max, sum2]]
  end

  def db_total(ms) do
    name = "Database"
    n    = Enum.sum(pluck(name, 0, ms))
    sum  = Enum.sum(pluck(name, 1, ms))
    min  = Enum.min(pluck(name, 3, ms), &zero/0)
    max  = Enum.max(pluck(name, 4, ms), &zero/0)
    sum2 = Enum.sum(pluck(name, 5, ms))

    [%{name: "Database/all", scope: ""}, [n, sum, sum, min, max, sum2]]
  end

  def errors_total(errors) do
    data = [length(errors), 0.0, 0.0, 0.0, 0.0, 0.0]
    [[%{name: "Errors/all", scope: ""}, data],
     [%{name: "Errors/allWeb", scope: ""}, data],
     [%{name: "Instance/Reporting", scope: ""}, data]
    ]
  end

  def pluck(type, position, metrics) do
    metrics
     |> Enum.filter(fn [%{name: name}, _data] -> String.contains?(name, type) end)
     |> Enum.map(fn [_metric, data] -> Enum.at(data, position) || 0 end)
  end

  defp class2bin(:db), do: "Database"
  defp class2bin(atom) when is_atom(atom) do
    String.capitalize to_string(atom)
  end

  defp bgscope2bin(scope) do
    "OtherTransaction/Python/#{scope}"
  end

  defp scope2bin(url) when is_binary(url) do
    "WebTransaction/Uri/#{url}"
  end

  defp zero, do: 0
end
