defmodule EnumDataCleanseTest do
  use ExUnit.Case

  alias EnumDataCleanse

  @moduletag :capture_log

  test "cleanse" do
    data = [
      %{name: "Ferrari Italia", type: :sports_car},
      %{name: "Honda Passport", type: :crossover},
      %{name: "Chevy Camaro", type: :sports_car},
      %{name: "Dodge Ram", type: :truck}
    ]

    [%{name: "Ferrari Italia"}, %{name: "Chevy Camaro"}] =
      data
      |> Enum.filter(&match?(:sports_car, &1[:type]))

    [%{name: "Honda Passport"}, %{name: "Dodge Ram"}] =
      data
      |> Enum.reject(&match?(:sports_car, &1[:type]))

    [%{name: "Honda Passport"}, %{name: "Dodge Ram"}] =
      data
      |> Enum.filter(&big?(&1))
  end

  defp big?(%{type: type}), do: type in [:truck, :crossover]
end
