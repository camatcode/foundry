defmodule EnumDataSummarizeTest do
  use ExUnit.Case

  alias EnumDataSummarize

  @moduletag :capture_log

  setup do
    inv = [
      %{year: 1967, make: "Chevy", model: "Camaro"},
      %{year: 2020, make: "Lamborghini", model: "Huracan"},
      %{year: 1994, make: "Honda", model: "Civic"},
      %{year: 2000, make: "Honda", model: "Accord"},
      %{year: 2004, make: "Mitsubishi", model: "Evolution 8"},
      # no year
      %{make: "Toyota", model: "Supra"},
      %{make: "Toyota", model: "MR2"},
      %{make: "Mazda", model: "RX-7"}
    ]

    %{inv: inv}
  end

  test "reduce", %{inv: inventory} do
    ["Chevy", "Honda", "Lamborghini", "Mazda", "Mitsubishi", "Toyota"] =
      inventory
      |> Enum.reduce(MapSet.new(), &MapSet.put(&2, &1[:make]))
      |> MapSet.to_list()
      |> IO.inspect()
  end

  test "reduce_while", %{inv: inventory} do
    {:error, :missing_year} =
      inventory
      |> Enum.reduce_while(
        MapSet.new(),
        fn
          %{year: year}, acc -> {:cont, MapSet.put(acc, year)}
          _, _ -> {:halt, {:error, :missing_year}}
        end
      )
  end

  test "frequencies_by", %{inv: inventory} do
    %{
      "chevy" => 1,
      "honda" => 2,
      "lamborghini" => 1,
      "mazda" => 1,
      "mitsubishi" => 1,
      "toyota" => 2
    } =
      inventory
      |> Enum.map(& &1[:make])
      |> Enum.frequencies_by(&String.downcase/1)
  end
end
