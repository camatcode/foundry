defmodule EnumDataCleanseTest do
  use ExUnit.Case

  @moduletag :capture_log

  test "cleanse" do
    data = [
      %{name: "Ferrari Italia", type: :sports_car},
      %{name: "Honda Passport", type: :crossover},
      %{name: "Chevy Camaro", type: :sports_car},
      %{name: "Dodge Ram", type: :truck}
    ]

    [%{name: "Ferrari Italia"}, %{name: "Chevy Camaro"}] = Enum.filter(data, &match?(:sports_car, &1[:type]))

    [%{name: "Honda Passport"}, %{name: "Dodge Ram"}] = Enum.reject(data, &match?(:sports_car, &1[:type]))

    [%{name: "Honda Passport"}, %{name: "Dodge Ram"}] = Enum.filter(data, &big?(&1))
  end

  defp big?(%{type: type}), do: type in [:truck, :crossover]
end
