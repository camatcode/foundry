defmodule EnumDataMassageTest do
  use ExUnit.Case

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

  test "group_by", %{inv: inventory} do
    # group_by
    %{
      "Chevy" => [%{year: 1967, model: "Camaro"}],
      "Honda" => [%{year: 1994, model: "Civic"}, %{year: 2000, model: "Accord"}],
      "Lamborghini" => [%{year: 2020, model: "Huracan"}],
      "Mazda" => [%{model: "RX-7"}],
      "Mitsubishi" => [%{year: 2004, model: "Evolution 8"}],
      "Toyota" => [%{model: "Supra"}, %{model: "MR2"}]
    } = Enum.group_by(inventory, & &1[:make])
  end

  test "sort_by", %{inv: inventory} do
    [
      "1. 1967 Chevy Camaro",
      "2. 1994 Honda Civic",
      "3. 2000 Honda Accord",
      "4. 2004 Mitsubishi Evolution 8",
      "5. 2020 Lamborghini Huracan",
      "6. Toyota Supra",
      "7. Toyota MR2",
      "8. Mazda RX-7"
    ] =
      inventory
      |> Enum.sort_by(& &1[:year])
      |> Enum.with_index(1)
      |> Enum.map(fn {car, index} ->
        ["#{index}.", car[:year], car[:make], car[:model]]
        |> Enum.filter(& &1)
        |> Enum.join(" ")
      end)
  end

  test "split_with", %{inv: inventory} do
    {[
       %{year: 1967, make: "Chevy", model: "Camaro"},
       %{year: 2020, make: "Lamborghini", model: "Huracan"},
       %{year: 1994, make: "Honda", model: "Civic"},
       %{year: 2000, make: "Honda", model: "Accord"},
       %{year: 2004, make: "Mitsubishi", model: "Evolution 8"}
     ],
     [%{make: "Toyota", model: "Supra"}, %{make: "Toyota", model: "MR2"}, %{make: "Mazda", model: "RX-7"}]} =
      Enum.split_with(inventory, & &1[:year])
  end

  test "map", %{inv: inventory} do
    [
      "1967 Chevy Camaro",
      "2020 Lamborghini Huracan",
      "1994 Honda Civic",
      "2000 Honda Accord",
      "2004 Mitsubishi Evolution 8"
    ] =
      inventory
      |> Enum.filter(& &1[:year])
      |> Enum.map(&"#{&1[:year]} #{&1[:make]} #{&1[:model]}")
  end
end
