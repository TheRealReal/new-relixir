defmodule NewRelixir.CurrentTransaction do
  @moduledoc """
  Keeps track of the New Relic transaction name for the current process.

  As soon as a request starts and its transaction name is determined, that
  name is stored in the process dictionary with `CurrentTransaction.get`.

  Later on, spawned descendent processes can still record custom calls and
  database operations under the same parent New Relic transaction.
  """
  @key :new_relixir_transaction

  @doc """
  Lookup through process ancestors and find the NewRelic transaction.

  This function permits you trigger async tasks in controller actions and
  still inform the external request time in the same context.
  """
  @spec get() :: {:ok, binary} | {:error, :not_found}
  def get do
    if transaction = Process.get(@key) || search_on_ancestors() do
      {:ok, transaction}
    else
      {:error, :not_found}
    end
  end

  @doc """
  Associate the given transaction with the current process.
  """
  @spec set(transaction :: term) :: binary | nil
  def set(transaction) when is_binary(transaction) do
    Process.put(@key, transaction)
    transaction
  end
  def set(_), do: nil

  # Getting the other processes info generate locks. That's why this
  # function puts NewRelic transaction in the current process dictionary,
  # to avoid lock in future external requests in this same process.
  defp search_on_ancestors do
    :"$ancestors"
    |> Process.get([])
    |> Enum.find_value(&extract_transaction/1)
    |> set
  end

  defp extract_transaction(pid) do
    case Process.info(pid, :dictionary) do
      {:dictionary, info} -> info[@key]
      _ -> nil
    end
  end
end
