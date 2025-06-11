defmodule ErlangTermStorageTest do
  use ExUnit.Case

  alias ErlangTermStorage

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

    [{1, "Alex", "Koutmos"}, {3, "Joe", "Smith"}, {2, "Hugo", "Barauna"}] =
      uniq_table
      |> :ets.select([
        {
          {:"$1", %{first: :"$2", last: :"$3", lang: :elixir}},
          [],
          [{{:"$1", :"$2", :"$3"}}]
        }
      ])


    3 =
      uniq_table
      |> :ets.select_count([
        {
          {:"$1", %{lang: :"$2"}},
          [{:==, :"$2", :elixir}],
          [true]
        }
      ])

    :ets.delete(uniq_table)
    # page 49
  end
end
