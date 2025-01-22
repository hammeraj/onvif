# Onvif

**Elixir interface for Onvif functions**

## Installation

The package can be installed by adding `onvif` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:onvif, "~> 0.5.0"}
  ]
end
```

## How to use

This library provides an interface for an Elixir application to make requests to Onvif compliant devices.
A request requires a `Device` struct which contains data necessary to successfully make the request, including
an address, username, password, a best guess at which authentication method will work, and paths for several
Onvif services, include Media and Device services. An Onvif compliant device should implement functions outlined
in Onvif documentation, depending on which profiles with which the device claims to be compliant. That said,
a disclaimer that nothing is guaranteed and devices may not respond to requests for services that should be
implemented.

To start, make a probe request:
```
> Onvif.Discovery.probe()
[
  %Onvif.Discovery.Probe{
    address: ...
  }
]
```

This will return a list of devices on the network that respond to Web Services Dynamic Discovery. The request
_should_ filter any non-video device but it is possibly that printers, etc. will show up and will need to be
filtered by application logic. If you already have information about the device, you can use:
```
> Onvif.Discovery.probe_by(ip_address: "127.0.0.1")
%Onvif.Discovery.Probe{
  address: [...],
  device_ip: "127.0.0.1",
  ...
}
```
More details in the `Onvif.Discovery.probe_by/1` docs.

Once you have a valid `Probe` struct, you can initialize a device.
```
> Onvif.Device.init(probe, username, password)
%Onvif.Device{
  ...
}
```