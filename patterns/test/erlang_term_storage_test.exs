defmodule ErlangTermStorageTest do
  use ExUnit.Case

  @moduletag :capture_log

  test ":set ETS" do
    # !! Mutable !!
    # set is default
    uniq_table = :ets.new(:my_table, [:set])
    # {key, object}
    user_1 = {1, %{first: "Alex", last: "Koutmos", lang: :elixir}}
    user_2 = {2, %{first: "Hugo", last: "Barauna", lang: :elixir}}
    user_3 = {3, %{first: "Joe", last: "Smith", lang: :elixir}}

    :ets.insert(uniq_table, user_1)
    :ets.insert(uniq_table, user_2)
    :ets.insert(uniq_table, user_3)

    [^user_3] = :ets.lookup(uniq_table, 3)
    [^user_2] = :ets.lookup(uniq_table, 2)
    [] = :ets.lookup(uniq_table, 100)

    # remember, :ets.fun2ms/1 in the shell

    [{1, "Alex", "Koutmos"}, {3, "Joe", "Smith"}, {2, "Hugo", "Barauna"}] =
      :ets.select(uniq_table, [{{:"$1", %{first: :"$2", last: :"$3", lang: :elixir}}, [], [{{:"$1", :"$2", :"$3"}}]}])

    3 = :ets.select_count(uniq_table, [{{:"$1", %{lang: :"$2"}}, [{:==, :"$2", :elixir}], [true]}])

    :ets.delete(uniq_table)
  end

  test ":bag ETS" do
    # :public - any process can read/write
    # :private - only the owning process can read/write
    metrics_table = :ets.new(:my_metrics_table, [:bag, :public])

    task =
      Task.async(fn ->
        :ets.insert(
          metrics_table,
          {:auth_attempt, %{user: "Alex", ts: NaiveDateTime.utc_now()}}
        )

        :ets.insert(
          metrics_table,
          {:auth_attempt, %{user: "Hugo", ts: NaiveDateTime.utc_now()}}
        )

        :ets.insert(
          metrics_table,
          {:new_user_created, %{user: "Jane", ts: NaiveDateTime.utc_now()}}
        )
      end)

    Task.await(task)

    [
      new_user_created: %{user: "Jane", ts: _time_1},
      auth_attempt: %{user: "Alex", ts: _time_2},
      auth_attempt: %{user: "Hugo", ts: _time_3}
    ] = :ets.tab2list(metrics_table)

    :ets.delete(metrics_table)
  end

  test "DETS - disk based ets" do
    tmp = System.tmp_dir!()
    path = Path.join(tmp, "dets_table.dets")

    on_exit(fn ->
      File.rm(path)
    end)

    {:ok, dets_table} = :dets.open_file(~c"#{path}", type: :bag)

    metrics_table = :ets.new(:my_metrics_table, [:bag, :public])

    task =
      Task.async(fn ->
        :ets.insert(
          metrics_table,
          {:auth_attempt, %{user: "Alex", ts: NaiveDateTime.utc_now()}}
        )

        :ets.insert(
          metrics_table,
          {:auth_attempt, %{user: "Hugo", ts: NaiveDateTime.utc_now()}}
        )

        :ets.insert(
          metrics_table,
          {:new_user_created, %{user: "Jane", ts: NaiveDateTime.utc_now()}}
        )
      end)

    Task.await(task)

    :ets.to_dets(metrics_table, dets_table)
    :dets.sync(dets_table)
  end
end
