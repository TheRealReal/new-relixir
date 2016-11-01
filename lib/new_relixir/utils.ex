defmodule NewRelixir.Utils do
  def short_module_name(module) do
    module |> Module.split |> join_without_prefix
  end

  defp join_without_prefix([module_name]), do: module_name
  defp join_without_prefix([_|name_parts]), do: Enum.join(name_parts, ".")
end
