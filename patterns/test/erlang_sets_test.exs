defmodule ErlangSetsTest do
  use ExUnit.Case

  @moduletag :capture_log

  test "sets" do
    assert %{} = :sets.new(version: 2)

    assert {:set, 0, 16, 16, 8, 80, 48, {[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []},
            {{[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []}}} =
             :sets.new()

    %{"jane@cool-app.com" => [], "john@cool-app.com" => []} =
      unique_emails =
      [version: 2]
      |> :sets.new()
      |> then(&:sets.add_element("john@cool-app.com", &1))
      |> then(&:sets.add_element("jane@cool-app.com", &1))
      |> then(&:sets.add_element("jane@cool-app.com", &1))

    ["jane@cool-app.com", "john@cool-app.com"] = :sets.to_list(unique_emails)
  end

  test "ordsets" do
    [] = :ordsets.new()

    ["Alex Koutmos", "Jane Smith"] =
      :ordsets.new()
      |> then(&:ordsets.add_element("Jane Smith", &1))
      |> then(&:ordsets.add_element("Alex Koutmos", &1))
      |> then(&:ordsets.add_element("Alex Koutmos", &1))
  end

  test "gb_sets (general balanced)" do
    # use when set > 100 elements
    [2, 10, 42] =
      :gb_sets.new()
      |> then(&:gb_sets.add_element(42, &1))
      |> then(&:gb_sets.add_element(2, &1))
      |> then(&:gb_sets.add_element(10, &1))
      |> then(&:gb_sets.add_element(10, &1))
      |> :gb_sets.to_list()
  end
end
