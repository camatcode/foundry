defmodule ErlangModTest do
  use ExUnit.Case

  alias ErlangMod

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
    File.read!("test/erlang_mod_test.exs")
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
    :erlang.memory() |> IO.inspect(label: :memory)
  end

  test "system_info" do
    :erlang.system_info(:system_version) |> IO.inspect(label: :sys_ver)
    :erlang.system_info(:atom_limit) |> IO.inspect(label: :atom_limit)
    :erlang.system_info(:ets_count) |> IO.inspect(label: :ets_count)
    :erlang.system_info(:schedulers) |> IO.inspect(label: :schedulers)
    :erlang.system_info(:emu_flavor) |> IO.inspect(label: :emu_flavor)
  end
end
