defmodule Onvif.Device do
  alias Onvif.Device
  alias Onvif.Discovery.Probe

  @enforce_keys [:username, :password, :address]

  @type t :: %__MODULE__{}

  defstruct @enforce_keys ++
              [
                :scopes,
                :manufacturer,
                :model,
                :firmware_version,
                :serial_number,
                :hardware_id,
                :ntp,
                :media_service_path,
                auth_type: :xml_auth,
                time_diff_from_system_secs: 0,
                port: 80,
                supports_media2?: false,
                device_service_path: "/onvif/device_service"
              ]

  @spec init(Onvif.Discovery.Probe.t(), String.t(), String.t(), boolean, boolean) ::
          {:error, any()}
          | %Device{}
  def init(%Probe{} = probe_match, username, password, use_https? \\ false, use_ipv6? \\ false) do
    with {:ok, device} <-
           device_from_probe_match(probe_match, username, password, use_https?, use_ipv6?),
         {:ok, device_with_datetime} <- get_date_time(device),
         {:ok, updated_device} <- guess_auth(device_with_datetime) do
      updated_device
      |> get_services()
      |> set_media_service_path()
    end
  end

  defp device_from_probe_match(%Probe{} = probe_match, username, password, use_https?, use_ipv6?) do
    scheme = if use_https?, do: "https", else: "http"

    uri =
      probe_match.address
      |> get_address(use_ipv6?)
      |> URI.parse()
      |> Map.put(:scheme, scheme)
      |> Map.put(:userinfo, "#{username}:#{password}")

    is_nvr? = if "tds:Device" in probe_match.types, do: false, else: true

    device = %Device{
      username: username,
      password: password,
      ip: URI.to_string(uri),
      port: uri.port,
      scopes: probe_match.scopes,
      is_nvr?: is_nvr?
    }

    {:ok, device}
  end

  defp get_address(addresses, use_ipv6?) do
    ipv6_address =
      Enum.find(addresses, fn address ->
        uri = URI.parse(address)
        String.contains?(uri.host, ":")
      end)

    if use_ipv6? and !is_nil(ipv6_address) do
      ipv6_address
    else
      Enum.at(addresses, 0)
    end
  end

  defp get_date_time(device) do
    with {:ok, res} <- Onvif.Devices.GetSystemDateAndTime.request(device.ip) do
      {:ok, Map.merge(device, Map.from_struct(res))}
    end
  end

  defp guess_auth(device, auth_types \\ [:xml_auth, :digest_auth, :basic_auth, :no_auth]) do
    if Enum.count(auth_types) == 0 do
      {:error, "Invalid credentials"}
    else
      [auth_type | rest] = auth_types

      case get_device_information(device, auth_type) do
        {:ok, %Device{} = updated_device} -> {:ok, Map.put(updated_device, :auth_type, auth_type)}
        {:error, _res} -> guess_auth(device, rest)
      end
    end
  end

  defp get_device_information(device, auth_type) do
    with {:ok, res} <-
           Onvif.Devices.GetDeviceInformation.request(
             device.ip,
             auth_type
           ) do
      {:ok, Map.merge(device, Map.from_struct(res))}
    end
  end

  defp get_services(device) do
    with {:ok, res} <-
           Onvif.Devices.GetServices.request(
             device.ip,
             device.auth_type
           ) do
      services =
        res
        |> Enum.map(&elem(&1, 1))

      Map.put(device, :services, services)
    end
  end

  defp set_media_service_path(device) do
    case get_media_ver20_service_path(device.services) do
      nil ->
        path = get_media_ver10_service_path(device.services)
        Map.put(device, :media_service_path, path)

      path ->
        device
        |> Map.put(:media_service_path, path)
        |> Map.put(:supports_media2?, true)
    end
  end

  defp get_media_ver20_service_path(services) do
    services
    |> Enum.find(&String.contains?(&1.namespace, "ver20/media"))
    |> then(& &1.xaddr)
    |> URI.parse()
    |> Map.get(:path)
  end

  defp get_media_ver10_service_path(services) do
    services
    |> Enum.find(&String.contains?(&1.namespace, "ver10/media"))
    |> then(& &1.xaddr)
    |> URI.parse()
    |> Map.get(:path)
  end
end
