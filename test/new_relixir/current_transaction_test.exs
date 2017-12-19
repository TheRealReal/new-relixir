defmodule NewRelixir.CurrentTransactionTest do
  use ExUnit.Case, async: true

  alias NewRelixir.CurrentTransaction

  describe "get/0" do
    test "gets existing transaction from the current process" do
      Process.put(:new_relixir_transaction, "the-transaction")

      assert {:ok, "the-transaction"} == CurrentTransaction.get()
    end

    test "gets transaction from grandparent process and sets on current when missing" do
      Process.put(:new_relixir_transaction, "ancestor-transaction")

      parent = Task.async fn ->
        child = Task.async(&CurrentTransaction.get/0)
        Task.await(child)
      end

      {:ok, transaction} = Task.await(parent)

      assert "ancestor-transaction" == transaction
    end

    test "returns error when missing from the current process dictionary and from ancestors" do
      assert {:error, :not_found} == CurrentTransaction.get()
    end
  end

  describe "set/1" do
    test "stores the given transaction in the process dictionary" do
      transaction = CurrentTransaction.set("the-transaction")

      assert "the-transaction" == transaction
      assert "the-transaction" == Process.get(:new_relixir_transaction)
    end

    test "does nothing with nil" do
      transaction = CurrentTransaction.set(nil)

      assert nil == transaction
      assert nil == Process.get(:new_relixir_transaction)
    end
  end
end
