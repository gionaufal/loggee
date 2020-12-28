defmodule LoggeeTest do
  use ExUnit.Case
  doctest Loggee

  test "greets the world" do
    assert Loggee.hello() == :world
  end
end
