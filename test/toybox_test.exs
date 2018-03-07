defmodule ToyboxTest do
  use ExUnit.Case
  doctest Toybox

  test "greets the world" do
    assert Toybox.hello() == :world
  end
end
