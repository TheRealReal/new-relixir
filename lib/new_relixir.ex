defmodule NewRelixir do
  @moduledoc """
  New Relic instrumentation for Elixir apps.
  """

  @doc """
  Tells if New Relixir is configured correctly and pushing data to New Relic.
  """
  @spec active? :: boolean
  def active? do
    Application.get_env(:new_relixir, :active)
  end
end
