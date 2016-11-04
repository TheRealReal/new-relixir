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
      record_call(:transaction, [Keyword.delete(opts, :conn), fun])
    end

    def rollback(value) do
      record_call(:rollback, [value])
    end

    def all(queryable, opts \\ []) do
      record_call(:all, [queryable, Keyword.delete(opts, :conn)])
    end

    def get(queryable, id, opts \\ []) do
      record_call(:get, [queryable, id, Keyword.delete(opts, :conn)])
    end

    def get!(queryable, id, opts \\ []) do
      record_call(:get!, [queryable, id, Keyword.delete(opts, :conn)])
    end

    def get_by(queryable, clauses, opts \\ []) do
      record_call(:get_by, [queryable, clauses, Keyword.delete(opts, :conn)])
    end

    def get_by!(queryable, clauses, opts \\ []) do
      record_call(:get_by!, [queryable, clauses, Keyword.delete(opts, :conn)])
    end

    def one(queryable, opts \\ []) do
      record_call(:one, [queryable, Keyword.delete(opts, :conn)])
    end

    def one!(queryable, opts \\ []) do
      record_call(:one!, [queryable, Keyword.delete(opts, :conn)])
    end

    def update_all(queryable, updates, opts \\ []) do
      record_call(:update_all, [queryable, updates, Keyword.delete(opts, :conn)])
    end

    def delete_all(queryable, opts \\ []) do
      record_call(:delete_all, [queryable, Keyword.delete(opts, :conn)])
    end

    def insert(model, opts \\ []) do
      record_call(:insert, [model, Keyword.delete(opts, :conn)])
    end

    def update(model, opts \\ []) do
      record_call(:update, [model, Keyword.delete(opts, :conn)])
    end

    def insert_or_update(changeset, opts \\ []) do
      record_call(:insert_or_update, [changeset, Keyword.delete(opts, :conn)])
    end

    def delete(model, opts \\ []) do
      record_call(:delete, [model, Keyword.delete(opts, :conn)])
    end

    def insert!(model, opts \\ []) do
      record_call(:insert!, [model, Keyword.delete(opts, :conn)])
    end

    def update!(model, opts \\ []) do
      record_call(:update!, [model, Keyword.delete(opts, :conn)])
    end

    def insert_or_update!(changeset, opts \\ []) do
      record_call(:insert_or_update!, [changeset, Keyword.delete(opts, :conn)])
    end

    def delete!(model, opts \\ []) do
      record_call(:delete!, [model, Keyword.delete(opts, :conn)])
    end

    def preload(model_or_models, preloads) do
      record_call(:preload, [model_or_models, preloads])
    end

    def __adapter__ do
    end

    def __query_cache__ do
    end

    def __repo__ do
    end

    def __pool__ do
    end

    def log(_entry) do
    end

    defp record_call(method_name, args) do
      :ok = :timer.sleep(@sleep_ms)
      {@sleep_ms * 1000, method_name, args}
    end

    defmodule NewRelic do
      use NewRelixir.Plug.Repo, repo: NewRelixir.Plug.RepoTest.FakeRepo
    end
  end

  import TestHelpers.Assertions
  import Plug.Conn

  alias NewRelixir.Plug.RepoTest.FakeRepo.NewRelic, as: Repo

  @transaction_name "TestTransaction"

  setup do
    conn = %Plug.Conn{}
    |> put_private(:new_relixir_transaction, NewRelixir.Transaction.start(@transaction_name))

    :ok = :statman_histogram.init

    {:ok, conn: conn}
  end

  # all

  test "all calls repo's all method", %{conn: conn} do
    assert Repo.all(FakeModel, conn: conn) == FakeRepo.all(FakeModel)
  end

  test "records time to call repo's all method", %{conn: conn} do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.all(FakeModel, conn: conn)
      time
    end)

    [{recorded_time, _}] = :statman_histogram.get_data({@transaction_name, {:db, "FakeModel.all"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # get

  test "get calls repo's get method", %{conn: conn} do
    id = :rand.uniform(1000)
    assert Repo.get(FakeModel, id, conn: conn) == FakeRepo.get(FakeModel, id)
  end

  test "records time to call repo's get method", %{conn: conn} do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.get(FakeModel, :rand.uniform(1000), conn: conn)
      time
    end)

    [{recorded_time, _}] = :statman_histogram.get_data({@transaction_name, {:db, "FakeModel.get"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # get!

  test "get! calls repo's get! method", %{conn: conn} do
    id = :rand.uniform(1000)
    assert Repo.get!(FakeModel, id, conn: conn) == FakeRepo.get!(FakeModel, id)
  end

  test "records time to call repo's get! method", %{conn: conn} do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.get!(FakeModel, :rand.uniform(1000), conn: conn)
      time
    end)

    [{recorded_time, _}] = :statman_histogram.get_data({@transaction_name, {:db, "FakeModel.get!"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # get_by

  test "get_by calls repo's get_by method", %{conn: conn} do
    assert Repo.get_by(FakeModel, [name: "Bob"], conn: conn) == FakeRepo.get_by(FakeModel, name: "Bob")
  end

  test "records time to call repo's get_by method", %{conn: conn} do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.get_by(FakeModel, [name: "Bob"], conn: conn)
      time
    end)

    [{recorded_time, _}] = :statman_histogram.get_data({@transaction_name, {:db, "FakeModel.get_by"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # get_by!

  test "get_by! calls repo's get_by! method", %{conn: conn} do
    assert Repo.get_by!(FakeModel, [name: "Bob"], conn: conn) == FakeRepo.get_by!(FakeModel, name: "Bob")
  end

  test "records time to call repo's get_by! method", %{conn: conn} do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.get_by!(FakeModel, [name: "Bob"], conn: conn)
      time
    end)

    [{recorded_time, _}] = :statman_histogram.get_data({@transaction_name, {:db, "FakeModel.get_by!"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # one

  test "one calls repo's one method", %{conn: conn} do
    assert Repo.one(FakeModel, conn: conn) == FakeRepo.one(FakeModel)
  end

  test "records time to call repo's one method", %{conn: conn} do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.one(FakeModel, conn: conn)
      time
    end)

    [{recorded_time, _}] = :statman_histogram.get_data({@transaction_name, {:db, "FakeModel.one"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # one!

  test "one! calls repo's one! method", %{conn: conn} do
    assert Repo.one!(FakeModel, conn: conn) == FakeRepo.one!(FakeModel)
  end

  test "records time to call repo's one! method", %{conn: conn} do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.one!(FakeModel, conn: conn)
      time
    end)

    [{recorded_time, _}] = :statman_histogram.get_data({@transaction_name, {:db, "FakeModel.one!"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # update_all

  test "update_all calls repo's update_all method", %{conn: conn} do
    assert Repo.update_all(FakeModel, [name: "Bob"], conn: conn) == FakeRepo.update_all(FakeModel, name: "Bob")
  end

  test "records time to call repo's update_all method", %{conn: conn} do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.update_all(FakeModel, %{name: "Bob"}, conn: conn)
      time
    end)

    [{recorded_time, _}] = :statman_histogram.get_data({@transaction_name, {:db, "FakeModel.update_all"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # delete_all

  test "delete_all calls repo's delete_all method", %{conn: conn} do
    assert Repo.delete_all(FakeModel, conn: conn) == FakeRepo.delete_all(FakeModel)
  end

  test "records time to call repo's delete_all method", %{conn: conn} do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.delete_all(FakeModel, conn: conn)
      time
    end)

    [{recorded_time, _}] = :statman_histogram.get_data({@transaction_name, {:db, "FakeModel.delete_all"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # insert

  test "insert calls repo's insert method", %{conn: conn} do
    assert Repo.insert(%FakeModel{}, conn: conn) == FakeRepo.insert(%FakeModel{})
  end

  test "records time to call repo's insert method", %{conn: conn} do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.insert(%FakeModel{}, conn: conn)
      time
    end)

    [{recorded_time, _}] = :statman_histogram.get_data({@transaction_name, {:db, "FakeModel.insert"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # update

  test "update calls repo's update method", %{conn: conn} do
    assert Repo.update(%FakeModel{}, conn: conn) == FakeRepo.update(%FakeModel{})
  end

  test "records time to call repo's update method", %{conn: conn} do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.update(%FakeModel{}, conn: conn)
      time
    end)

    [{recorded_time, _}] = :statman_histogram.get_data({@transaction_name, {:db, "FakeModel.update"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # insert_or_update

  test "insert_or_update calls repo's insert_or_update method", %{conn: conn} do
    assert Repo.insert_or_update(%FakeModel{}, conn: conn) == FakeRepo.insert_or_update(%FakeModel{})
  end

  test "records time to call repo's insert_or_update method", %{conn: conn} do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.insert_or_update(%FakeModel{}, conn: conn)
      time
    end)

    [{recorded_time, _}] = :statman_histogram.get_data({@transaction_name, {:db, "FakeModel.insert_or_update"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # delete

  test "delete calls repo's delete method", %{conn: conn} do
    assert Repo.delete(%FakeModel{}, conn: conn) == FakeRepo.delete(%FakeModel{})
  end

  test "records time to call repo's delete method", %{conn: conn} do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.delete(%FakeModel{}, conn: conn)
      time
    end)

    [{recorded_time, _}] = :statman_histogram.get_data({@transaction_name, {:db, "FakeModel.delete"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # insert!

  test "insert! calls repo's insert! method", %{conn: conn} do
    assert Repo.insert!(%FakeModel{}, conn: conn) == FakeRepo.insert!(%FakeModel{})
  end

  test "records time to call repo's insert! method", %{conn: conn} do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.insert!(%FakeModel{}, conn: conn)
      time
    end)

    [{recorded_time, _}] = :statman_histogram.get_data({@transaction_name, {:db, "FakeModel.insert!"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # update!

  test "update! calls repo's update! method", %{conn: conn} do
    assert Repo.update!(%FakeModel{}, conn: conn) == FakeRepo.update!(%FakeModel{})
  end

  test "records time to call repo's update! method", %{conn: conn} do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.update!(%FakeModel{}, conn: conn)
      time
    end)

    [{recorded_time, _}] = :statman_histogram.get_data({@transaction_name, {:db, "FakeModel.update!"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # insert_or_update!

  test "insert_or_update! calls repo's insert_or_update! method", %{conn: conn} do
    assert Repo.insert_or_update!(%FakeModel{}, conn: conn) == FakeRepo.insert_or_update!(%FakeModel{})
  end

  test "records time to call repo's insert_or_update! method", %{conn: conn} do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.insert_or_update!(%FakeModel{}, conn: conn)
      time
    end)

    [{recorded_time, _}] = :statman_histogram.get_data({@transaction_name, {:db, "FakeModel.insert_or_update!"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # delete!

  test "delete! calls repo's delete! method", %{conn: conn} do
    assert Repo.delete!(%FakeModel{}, conn: conn) == FakeRepo.delete!(%FakeModel{})
  end

  test "records time to call repo's delete! method", %{conn: conn} do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.delete!(%FakeModel{}, conn: conn)
      time
    end)

    [{recorded_time, _}] = :statman_histogram.get_data({@transaction_name, {:db, "FakeModel.delete!"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # preload

  test "preload calls repo's preload method", %{conn: conn} do
    assert Repo.preload(%FakeModel{}, [:foo, :bar], conn: conn) == FakeRepo.preload(%FakeModel{}, [:foo, :bar])
  end

  test "records time to call repo's preload method", %{conn: conn} do
    {elapsed_time, sleep_time} = :timer.tc(fn ->
      {time, _, _} = Repo.preload(%FakeModel{}, [:foo, :bar], conn: conn)
      time
    end)

    [{recorded_time, _}] = :statman_histogram.get_data({@transaction_name, {:db, "FakeModel.preload"}})
    assert_between(recorded_time, sleep_time, elapsed_time)
  end

  # transaction

  test "transaction calls repo's transaction method", %{conn: _conn} do
    assert Repo.transaction(&:rand.uniform/0) == FakeRepo.transaction(&:rand.uniform/0)
  end

  test "does not record time to call repo's transaction method", %{conn: _conn} do
    Repo.transaction(&:rand.uniform/0)

    assert Enum.empty?(:statman_histogram.keys)
  end

  # rollback

  test "rollback calls repo's rollback method", %{conn: _conn} do
    assert Repo.rollback(:foo) == FakeRepo.rollback(:foo)
  end

  test "does not record time to call repo's rollback method", %{conn: _conn} do
    Repo.rollback(:foo)

    assert Enum.empty?(:statman_histogram.keys)
  end
end
