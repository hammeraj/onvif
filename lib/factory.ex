defmodule Onvif.Factory do
  @moduledoc false

  def device do
    %Onvif.Device{
      address: "http://192.168.254.89",
      auth_type: :digest_auth,
      device_service_path: "/onvif/device_service",
      firmware_version: nil,
      hardware_id: "V1.0",
      manufacturer: "General",
      media_ver10_service_path: "/onvif/media_service",
      media_ver20_service_path: "/onvif/media2_service",
      replay_ver10_service_path: "/onvif/replay_service",
      recording_ver10_service_path: "/onvif/recording_service",
      search_ver10_service_path: "/onvif/search_service",
      ptz_ver20_service_path: "/onvif/ptz_service",
      model: "N864A6",
      ntp: "NTP",
      password: "admin",
      port: 80,
      scopes: [
        "onvif://www.onvif.org/location/country/China",
        "onvif://www.onvif.org/name/General",
        "onvif://www.onvif.org/hardware/N864A6",
        "onvif://www.onvif.org/Profile/Streaming",
        "onvif://www.onvif.org/type/Network_Video_Transmitter",
        "onvif://www.onvif.org/extension/unique_identifier/1",
        "onvif://www.onvif.org/Profile/G",
        "onvif://www.onvif.org/Profile/T"
      ],
      serial_number: "NV012306000836",
      services: [
        %Onvif.Devices.Schemas.Service{
          namespace: "http://www.onvif.org/ver10/replay/wsdl",
          version: "17.06",
          xaddr: "http://192.168.254.89/onvif/replay_service"
        },
        %Onvif.Devices.Schemas.Service{
          namespace: "http://www.onvif.org/ver10/search/wsdl",
          version: "18.12",
          xaddr: "http://192.168.254.89/onvif/search_service"
        },
        %Onvif.Devices.Schemas.Service{
          namespace: "http://www.onvif.org/ver10/recording/wsdl",
          version: "18.06",
          xaddr: "http://192.168.254.89/onvif/recording_service"
        },
        %Onvif.Devices.Schemas.Service{
          namespace: "http://www.onvif.org/ver10/deviceIO/wsdl",
          version: "18.12",
          xaddr: "http://192.168.254.89/onvif/deviceIO_service"
        },
        %Onvif.Devices.Schemas.Service{
          namespace: "http://www.onvif.org/ver10/events/wsdl",
          version: "2.60",
          xaddr: "http://192.168.254.89/onvif/event_service"
        },
        %Onvif.Devices.Schemas.Service{
          namespace: "http://www.onvif.org/ver20/ptz/wsdl",
          version: "18.12",
          xaddr: "http://192.168.254.89/onvif/ptz_service"
        },
        %Onvif.Devices.Schemas.Service{
          namespace: "http://www.onvif.org/ver20/media/wsdl",
          version: "18.12",
          xaddr: "http://192.168.254.89/onvif/media2_service"
        },
        %Onvif.Devices.Schemas.Service{
          namespace: "http://www.onvif.org/ver10/media/wsdl",
          version: "18.06",
          xaddr: "http://192.168.254.89/onvif/media_service"
        },
        %Onvif.Devices.Schemas.Service{
          namespace: "http://www.onvif.org/ver20/imaging/wsdl",
          version: "18.12",
          xaddr: "http://192.168.254.89/onvif/imaging_service"
        },
        %Onvif.Devices.Schemas.Service{
          namespace: "http://www.onvif.org/ver20/analytics/wsdl",
          version: "18.12",
          xaddr: "http://192.168.254.89/onvif/analytics_service"
        },
        %Onvif.Devices.Schemas.Service{
          namespace: "http://www.onvif.org/ver10/device/wsdl",
          version: "18.12",
          xaddr: "http://192.168.254.89/onvif/device_service"
        },
        %Onvif.Devices.Schemas.Service{
          namespace: "http://www.onvif.org/ver20/ptz/wsdl",
          xaddr: "http://192.168.254.89/onvif/ptz_service",
          version: "22.12"
        }
      ],
      time_diff_from_system_secs: 3597,
      username: "admin"
    }
  end
end
