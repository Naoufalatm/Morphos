defmodule TranspilerTest do
  use ExUnit.Case
  doctest Transpiler

  test "greets the world" do
    assert Transpiler.hello() == :world
  end
end
