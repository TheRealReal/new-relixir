defmodule NewRelixir.Plug.RepoTest do
  use ExUnit.Case, async: false

  defmodule FakeRepo do
    @behaviour Ecto.Repo

    @sleep_ms :rand.uniform(20)

    def config do
    end

    def start_link(_opts \\ []) do
    end

    def stop(_pid, _timeout \\ 5000) do
    end

    def transaction(opts \\ [], fun) when is_list(opts) do
      record_call(:transaction, [opts, fun])
    end

    def rollback(value) do
      record_call(:rollback, [value])
    end

    def all(queryable, opts \\ []) do
      record_call(:all, [queryable, opts])
    end

    def get(queryable, id, opts \\ []) do
      record_call(:get, [queryable, id, opts])
    end

    def get!(queryable, id, opts \\ []) do
      record_call(:get!, [queryable, id, opts])
    end

    def get_by(queryable, clauses, opts \\ []) do
      record_call(:get_by, [queryable, clauses, opts])
    end

    def get_by!(queryable, clauses, opts \\ []) do
      record_call(:get_by!, [queryable, clauses, opts])
    end

    def one(queryable, opts \\ []) do
      record_call(:one, [queryable, opts])
    end

    def one!(queryable, opts \\ []) do
      record_call(:one!, [queryable, opts])
    end

    def insert_all(schema_or_source, entries, opts \\ []) do
      record_call(:insert_all, [schema_or_source, entries, opts])
    end

    def update_all(queryable, updates, opts \\ []) do
      record_call(:update_all, [queryable, updates, opts])
    end

    def delete_all(queryable, opts \\ []) do
      record_call(:delete_all, [queryable, opts])
    end

    def insert(model, opts \\ []) do
      record_call(:insert, [model, opts])
    end

    def update(model, opts \\ []) do
      record_call(:update, [model, opts])
    end

    def insert_or_update(changeset, opts \\ []) do
      record_call(:insert_or_update, [changeset, opts])
    end

    def delete(model, opts \\ []) do
      record_call(:delete, [model, opts])
    end

    def insert!(model, opts \\ []) do
      record_call(:insert!, [model, opts])
    end

    def update!(model, opts \\ []) do
      record_call(:update!, [model, opts])
    end

    def insert_or_update!(changeset, opts \\ []) do
      record_call(:insert_or_update!, [changeset, opts])
    end

    def delete!(model, opts \\ []) do
      record_call(:delete!, [model, opts])
    end

    def aggregate(queryable, aggregate, field, opts \\ []) do
      record_call(:aggregate, [queryable, aggregate, field, opts])
    end

    def preload(model_or_models, preloads, opts \\ []) do
      record_call(:preload, [model_or_models, preloads, opts])
    end

    def __adapter__ do
    end

    def __query_cache__ do
    end

    def __repo__ do
    end

    def __pool__ do
    end

    def __log__(_entry) do
    end

    defp record_call(function_name, args) do
      :ok = :timer.sleep(@sleep_ms)
      {@sleep_ms * 1000, function_name, args}
    end

    defmodule NewRelic do
      use NewRelixir.Plug.Repo, repo: NewRelixir.Plug.RepoTest.FakeRepo
    end
  end

  import TestHelpers.Assertions

  alias NewRelixir.Plug.RepoTest.FakeRepo.NewRelic, as: Repo

  @transaction_name "TestTransaction"

  setup do
    NewRelixir.CurrentTransaction.set(@transaction_name)

    :ok
  end

  # all

  test "all calls repo's all method" do
    assert Repo.all(FakeModel) == FakeRepo.all(FakeModel)
  end

  test "records time to call repo's all method" do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.all(FakeModel)
      time
    end)

    [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.all"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # get

  test "get calls repo's get method" do
    id = :rand.uniform(1000)
    assert Repo.get(FakeModel, id) == FakeRepo.get(FakeModel, id)
  end

  test "records time to call repo's get method" do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.get(FakeModel, :rand.uniform(1000))
      time
    end)

    [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.get"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # get!

  test "get! calls repo's get! method" do
    id = :rand.uniform(1000)
    assert Repo.get!(FakeModel, id) == FakeRepo.get!(FakeModel, id)
  end

  test "records time to call repo's get! method" do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.get!(FakeModel, :rand.uniform(1000))
      time
    end)

    [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.get!"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # get_by

  test "get_by calls repo's get_by method" do
    assert Repo.get_by(FakeModel, [name: "Bob"]) == FakeRepo.get_by(FakeModel, name: "Bob")
  end

  test "records time to call repo's get_by method" do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.get_by(FakeModel, [name: "Bob"])
      time
    end)

    [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.get_by"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # get_by!

  test "get_by! calls repo's get_by! method" do
    assert Repo.get_by!(FakeModel, [name: "Bob"]) == FakeRepo.get_by!(FakeModel, name: "Bob")
  end

  test "records time to call repo's get_by! method" do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.get_by!(FakeModel, [name: "Bob"])
      time
    end)

    [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.get_by!"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # one

  test "one calls repo's one method" do
    assert Repo.one(FakeModel) == FakeRepo.one(FakeModel)
  end

  test "records time to call repo's one method" do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.one(FakeModel)
      time
    end)

    [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.one"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # one!

  test "one! calls repo's one! method" do
    assert Repo.one!(FakeModel) == FakeRepo.one!(FakeModel)
  end

  test "records time to call repo's one! method" do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.one!(FakeModel)
      time
    end)

    [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.one!"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  describe "insert_all/3" do
    test "insert_all calls repo's insert_all method" do
      assert Repo.insert_all(FakeModel, [[name: "Bob"], [name: "Jake"]]) == FakeRepo.insert_all(FakeModel, [[name: "Bob"], [name: "Jake"]])
    end

    test "records time to call repo's insert_all method" do
      {elapsed_time, sleep_time} = :timer.tc(fn ->
        {time, _, _} = Repo.insert_all(FakeModel, [%{name: "Bob"}, %{name: "Jake"}])
        time
      end)

      [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.insert_all"}})
      assert_between(recorded_time, sleep_time, elapsed_time)
    end
  end


  # update_all

  test "update_all calls repo's update_all method" do
    assert Repo.update_all(FakeModel, [name: "Bob"]) == FakeRepo.update_all(FakeModel, name: "Bob")
  end

  test "records time to call repo's update_all method" do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.update_all(FakeModel, %{name: "Bob"})
      time
    end)

    [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.update_all"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # delete_all

  test "delete_all calls repo's delete_all method" do
    assert Repo.delete_all(FakeModel) == FakeRepo.delete_all(FakeModel)
  end

  test "records time to call repo's delete_all method" do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.delete_all(FakeModel)
      time
    end)

    [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.delete_all"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # insert

  test "insert calls repo's insert method" do
    assert Repo.insert(%FakeModel{}) == FakeRepo.insert(%FakeModel{})
  end

  test "records time to call repo's insert method" do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.insert(%FakeModel{})
      time
    end)

    [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.insert"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # update

  test "update calls repo's update method" do
    assert Repo.update(%FakeModel{}) == FakeRepo.update(%FakeModel{})
  end

  test "records time to call repo's update method" do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.update(%FakeModel{})
      time
    end)

    [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.update"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # insert_or_update

  test "insert_or_update calls repo's insert_or_update method" do
    assert Repo.insert_or_update(%FakeModel{}) == FakeRepo.insert_or_update(%FakeModel{})
  end

  test "records time to call repo's insert_or_update method" do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.insert_or_update(%FakeModel{})
      time
    end)

    [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.insert_or_update"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # delete

  test "delete calls repo's delete method" do
    assert Repo.delete(%FakeModel{}) == FakeRepo.delete(%FakeModel{})
  end

  test "records time to call repo's delete method" do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.delete(%FakeModel{})
      time
    end)

    [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.delete"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # insert!

  test "insert! calls repo's insert! method" do
    assert Repo.insert!(%FakeModel{}) == FakeRepo.insert!(%FakeModel{})
  end

  test "records time to call repo's insert! method" do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.insert!(%FakeModel{})
      time
    end)

    [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.insert!"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # update!

  test "update! calls repo's update! method" do
    assert Repo.update!(%FakeModel{}) == FakeRepo.update!(%FakeModel{})
  end

  test "records time to call repo's update! method" do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.update!(%FakeModel{})
      time
    end)

    [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.update!"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # insert_or_update!

  test "insert_or_update! calls repo's insert_or_update! method" do
    assert Repo.insert_or_update!(%FakeModel{}) == FakeRepo.insert_or_update!(%FakeModel{})
  end

  test "records time to call repo's insert_or_update! method" do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.insert_or_update!(%FakeModel{})
      time
    end)

    [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.insert_or_update!"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # delete!

  test "delete! calls repo's delete! method" do
    assert Repo.delete!(%FakeModel{}) == FakeRepo.delete!(%FakeModel{})
  end

  test "records time to call repo's delete! method" do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.delete!(%FakeModel{})
      time
    end)

    [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.delete!"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # aggregate

  test "aggregate calls repo's aggregate method" do
    assert Repo.aggregate(FakeModel, :count, :id) == FakeRepo.aggregate(FakeModel, :count, :id)
  end

  test "records time to call repo's aggregate method" do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.aggregate(FakeModel, :count, :id)
      time
    end)

    [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.aggregate"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  describe "preload/3" do
    test "calls repo's preload method" do
      assert Repo.preload(%FakeModel{}, [:foo, :bar]) == FakeRepo.preload(%FakeModel{}, [:foo, :bar])
    end

    test "works with list of structs"  do
      assert Repo.preload([%FakeModel{}, %FakeModel{}], [:foo, :bar]) == FakeRepo.preload([%FakeModel{}, %FakeModel{}], [:foo, :bar])
    end

    test "records time to call repo's preload method" do
      {elapsed_time, sleep_time} = :timer.tc(fn ->
        {time, _, _} = Repo.preload(%FakeModel{}, [:foo, :bar])
        time
      end)

      [recorded_time | _] = get_metric_by_key({@transaction_name, {:db, "FakeModel.preload"}})
      assert_between(recorded_time, sleep_time, elapsed_time)
    end
  end

  # transaction

  test "transaction calls repo's transaction method" do
    assert Repo.transaction(&:rand.uniform/0) == FakeRepo.transaction(&:rand.uniform/0)
  end

  test "does not record time to call repo's transaction method" do
    get_metric_keys()
    Repo.transaction(&:rand.uniform/0)

    assert Enum.empty?(get_metric_keys())
  end

  # rollback

  test "rollback calls repo's rollback method" do
    assert Repo.rollback(:foo) == FakeRepo.rollback(:foo)
  end

  test "does not record time to call repo's rollback method" do
    get_metric_keys()
    Repo.rollback(:foo)

    assert Enum.empty?(get_metric_keys())
  end
end
