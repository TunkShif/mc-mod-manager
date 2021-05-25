defmodule McModManagerTest do
  use ExUnit.Case
  doctest McModManager

  test "greets the world" do
    assert McModManager.hello() == :world
  end
end
