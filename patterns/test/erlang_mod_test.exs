defmodule ErlangModTest do
  use ExUnit.Case

  @moduletag :capture_log

  test "binary_to_term, term_to_binary" do
    serialized =
      %{some: "data", val: 42, lang: "en"}
      |> :erlang.term_to_binary()
      |> Base.encode64()

    # safe ensures the beam won't crash if atoms are created that would overflow the atom table
    %{some: "data", val: 42, lang: "en"} =
      serialized
      |> Base.decode64!()
      |> :erlang.binary_to_term([:safe])
  end

  test "md5" do
    "test/erlang_mod_test.exs"
    |> File.read!()
    |> :erlang.md5()
    |> IO.inspect(label: :md5)
  end

  test "phash2" do
    shards = 10

    1..100_000
    |> Enum.reduce(%{}, fn number, acc ->
      index = :erlang.phash2("Some data - #{number}", shards)
      Map.update(acc, index, 1, &(&1 + 1))
    end)
    |> IO.inspect(label: :phash2)
  end

  test "memory" do
    # bytes
    IO.inspect(:erlang.memory(), label: :memory)
  end

  test "system_info" do
    :system_version |> :erlang.system_info() |> IO.inspect(label: :sys_ver)
    :atom_limit |> :erlang.system_info() |> IO.inspect(label: :atom_limit)
    :ets_count |> :erlang.system_info() |> IO.inspect(label: :ets_count)
    :schedulers |> :erlang.system_info() |> IO.inspect(label: :schedulers)
    :emu_flavor |> :erlang.system_info() |> IO.inspect(label: :emu_flavor)
  end
end
