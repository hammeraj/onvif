defmodule Onvif.DeviceTest do
  use ExUnit.Case, async: true

  @moduletag capture_log: true

  describe "to_struct/1" do
    test "should parse given map to a valid device struct" do
      device_map = Onvif.Factory.device() |> Jason.encode!() |> Jason.decode!()
      {:ok, device} = Onvif.Device.to_struct(device_map)
      assert device == Onvif.Factory.device()
    end
  end
end
