defmodule ErlangPersistentTermTest do
  use ExUnit.Case

  @moduletag :capture_log

  test "persistent term" do
    _terms = :persistent_term.get()
    k = {:my_app, :my_key}
    :persistent_term.put(k, %{some: "Data", that: "Rarely", ever: "Changes"})

    %{some: "Data", that: "Rarely", ever: "Changes"} = :persistent_term.get(k)
  end
end
