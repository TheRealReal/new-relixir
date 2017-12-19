defmodule NewRelixir.TransactionTest do
  use ExUnit.Case

  import TestHelpers.Assertions

  alias NewRelixir.Transaction

  describe "record_web/2" do
    test "adds web transactions to the collector" do
      Transaction.record_web("a-web-transaction", 1_234)
      Transaction.record_web("a-web-transaction", 2_345)

      assert [2_345, 1_234] == get_metric_by_key({"a-web-transaction", :total})
    end
  end

  describe "record_db/3" do
    test "adds database segments to the collector" do
      Transaction.record_db("a-db-transaction", "Blog.Post.get", 1_234)
      Transaction.record_db("a-db-transaction", "Blog.Post.get", 2_345)

      assert [2_345, 1_234] == get_metric_by_key({"a-db-transaction", {:db, "Blog.Post.get"}})
    end
  end

  describe "record_external/3" do
    test "adds web transactions to the collector" do
      Transaction.record_external("an-ext-transaction", "a-host.com", 1_234)
      Transaction.record_external("an-ext-transaction", "a-host.com", 2_345)

      assert [2_345, 1_234] == get_metric_by_key({"an-ext-transaction", {:ext, "a-host.com"}})
    end
  end
end
