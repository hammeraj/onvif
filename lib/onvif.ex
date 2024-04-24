defmodule Onvif do
  @moduledoc """
  Interface for making requests to an Onvif compatible device.

  Currently supports WS Discovery probing, a subset of Device wsdl functions
  and a subset of Media wsdl functions.
  """

  def setup do
    [probe] = Onvif.Discovery.probe()
    {:ok, device} = Onvif.Device.init(probe, "admin", "1410Cro$$")
    device
  end
end
