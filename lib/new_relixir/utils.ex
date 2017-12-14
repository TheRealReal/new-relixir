defmodule NewRelixir.Utils do
  import Phoenix.Controller, only: [controller_module: 1, action_name: 1]

  def transaction_name(conn) do
    module = conn |> controller_module |> short_module_name
    action = conn |> action_name
    "#{module}##{action}"
  end

  def short_module_name(module) do
    module |> Module.split |> join_without_prefix
  end

  defp join_without_prefix([module_name]), do: module_name
  defp join_without_prefix([_|name_parts]), do: Enum.join(name_parts, ".")
end
