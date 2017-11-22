defmodule NewRelic.Statman do
  def poll do
    [metrics, errors] = NewRelic.Collector.poll
    transform_aggregated_metrics([metrics, errors])
  end

  def transform_aggregated_metrics([metrics, errors]) do
    ms = metrics
      |> Map.to_list
      |> Enum.map(fn(m) -> transform_metric(m) end)
      |> Enum.filter(&(&1 != []))

    errs = errors |> Map.to_list |> Enum.map(fn(metric) -> transform_error_counter(metric) end)

    {[webtransaction_total(ms), db_total(ms) | errors_total(errs) ++ ms], errs}
  end

  def transform_error_counter({{scope, type, message}, count}) do
    error = [
      :os.system_time(:micro_seconds) / 1_000_000,
      scope2bin(scope),
      to_bin(message),
      to_bin(type),
      [%{
        parameter_groups: %{},
        stack_trace: [],
        request_params: %{},
        request_uri: scope}]
    ]
    List.duplicate(error, count) |> List.flatten
  end

  defp transform_metric(metric) do
    transform_histogram(metric)
  end


  def transform_counter(metric) do
    case metric[:key] do
      {scope, {:error, {_type, _message}}} when is_binary(scope) ->
        errors_count = metric[:value]
        if errors_count > 0 do
          [[%{name: "Errors/WebTransaction/Uri/#{scope}", scope: ""}, [errors_count, 0.0, 0.0, 0.0, 0.0, 0.0]
           ]]
        else
          []
        end
      _ -> []
    end
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
         [%{name: "Database/#{to_bin(segment)}", scope: scope2bin(scope)}, data],
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
          [%{name: bgscope2bin(scope), scope: ""}, data]

      {{:background, scope}, {class, segment}} when is_binary(scope) ->
          [%{name: class2bin(class) <> "/" <> to_bin(segment), scope: bgscope2bin(scope)}, data]

      {scope, {class, segment}} when is_binary(scope) ->
          [%{name: class2bin(class) <> "/" <> to_bin(segment), scope: scope2bin(scope)}, data]

      {scope, :total} when is_binary(scope) ->
          [%{name: "WebTransaction/Uri/#{scope}", scope: ""}, data]

      {a, b} when is_atom(a) and is_atom(b) ->
          [%{name: "OtherTransaction/#{a}/#{b}", scope: ""}, data]
      _ ->
          []
    end
  end

  def webtransaction_total(ms) do
    name = "WebTransaction"
    n    = Enum.sum(pluck(name, 1, ms))
    sum  = Enum.sum(pluck(name, 2, ms))
    min  = Enum.min(pluck(name, 4, ms))
    max  = Enum.max(pluck(name, 5, ms))
    sum2 = Enum.sum(pluck(name, 6, ms))

    [%{name: "HttpDispatcher", scope: ""}, [n, sum, sum, min, max, sum2]]
  end

  def db_total(ms) do
    name = "Database"
    n    = Enum.sum(pluck(name, 1, ms))
    sum  = Enum.sum(pluck(name, 2, ms))
    min  = Enum.min(pluck(name, 4, ms))
    max  = Enum.max(pluck(name, 5, ms))
    sum2 = Enum.sum(pluck(name, 6, ms))

    [%{name: "Database/all", scope: ""}, [n, sum, sum, min, max, sum2]]
  end

  def errors_total(errors) do
    data = [length(errors), 0.0, 0.0, 0.0, 0.0, 0.0]
    [[%{name: "Errors/all", scope: ""}, data],
     [%{name: "Errors/allWeb", scope: ""}, data],
     [%{name: "Instance/Reporting", scope: ""}, data]
    ]
  end

  def pluck(_, _, []), do: [0]
  def pluck(name, n, list) do
    Enum.map(list, fn(elem) -> get_nth(elem, name, n-1) end)
  end

  defp get_nth([[_, []]], _, _), do: 0
  defp get_nth([_, []], _, _), do: 0
  defp get_nth([[struct, data_list]], name, n), do: get_nth([struct, data_list], name, n)
  defp get_nth([struct, data_list], name, n) do
    if String.contains?(struct[:name], name) do
      if struct[:scope] == "" do
        Enum.at(data_list, n) || 0
      else
        0
      end
    else
      0
    end
  end



  defp class2bin(:db), do: "Database"
  defp class2bin(atom) when is_atom(atom) do
    String.capitalize to_string(atom)
  end

  defp to_bin(atom) when is_atom(atom) do
    to_string(atom)
  end
  defp to_bin(binary) when is_binary(binary) do
    binary
  end

  defp bgscope2bin(scope) do
    "OtherTransaction/Python/#{scope}"
  end

  defp scope2bin(url) when is_binary(url) do
    "WebTransaction/Uri/#{url}"
  end

end
