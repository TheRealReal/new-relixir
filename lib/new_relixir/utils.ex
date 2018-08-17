defmodule NewRelixir.Utils do
  alias Plug.Conn

  @doc """
  Derives a transaction name from the current context.

  If in a Phoenix app, it is composed of controller and action name.
  If in a Plug-only app, it is made out of request path and method.
  """
  def transaction_name(%Conn{private: %{phoenix_action: action, phoenix_controller: controller}}) do
    "#{short_module_name(controller)}##{action}"
  end

  def transaction_name(%Conn{request_path: "/" <> path, method: method}) do
    "#{path}##{method}"
  end

  def transaction_name(_), do: nil

  def short_module_name(module) do
    module
    |> Module.split()
    |> join_without_prefix()
  end

  defp join_without_prefix([module_name]), do: module_name
  defp join_without_prefix([_ | name_parts]), do: Enum.join(name_parts, ".")
end
