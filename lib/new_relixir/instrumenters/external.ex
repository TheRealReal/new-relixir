defmodule NewRelixir.Instrumenters.External do
  @moduledoc """
  This instrumenter measures total time of each external request
  made in the context of an application request.
  """

  alias NewRelixir.{CurrentTransaction, Transaction}

  require Logger

  def external_http_request(:start, _compile_metadata, %{url: url}) do
    url
  end

  def external_http_request(:stop, elapsed_time, url) do
    with true <- NewRelixir.active?,
         {:ok, transaction} <- CurrentTransaction.get(),
           %{host: host} when is_binary(host) <- URI.parse(url) do

      elapsed_microseconds = System.convert_time_unit(elapsed_time, :native, :microsecond)

      Transaction.record_external(transaction, host, elapsed_microseconds)

      Logger.debug fn ->
        elapsed_milliseconds = System.convert_time_unit(elapsed_time, :native, :millisecond)
        "External request to #{url} finished in #{elapsed_milliseconds}ms"
      end
    end
  end
end
