defmodule NewRelixir.Instrumenters.Phoenix do
  @moduledoc """
  New Relic instrumenter for Phoenix controllers.

  It relies on the instrumentation API provided by `Phoenix.Endpoint`. To set it up,
  include this module in the list of `instrumenters` of your Endpoint config:

      config :my_app, MyAppWeb.Endpoint,
        instrumenters: [NewRelixir.Instrumenters.Phoenix],

  """
  alias NewRelixir.Utils

  def phoenix_controller_call(:start, _compile_metadata, %{conn: conn}) do
    if NewRelixir.active?, do: Utils.transaction_name(conn)
  end

  def phoenix_controller_call(:stop, elapsed_time, transaction_name) do
    if NewRelixir.active? do
      elapsed_microseconds = System.convert_time_unit(elapsed_time, :native, :microsecond)

      NewRelixir.Collector.record_value({transaction_name, :total}, elapsed_microseconds)
    end
  end
end
