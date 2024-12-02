defmodule Onvif.Replay.ServiceCapabilities do
  @fields [
    rtp_rtsp_tcp: false,
    reverse_playback: false,
    session_timeout_range: "0",
    rtsp_web_socket_uri: false,
    receive_source: false,
    media_profile_source: false,
    dynamic_recordings: false,
    dynamic_tracks: false,
    max_string_length: "0"
  ]

  defstruct Keyword.keys(@fields)

  @type t() :: %__MODULE__{
          rtp_rtsp_tcp: boolean(),
          reverse_playback: boolean(),
          session_timeout_range: String.t(),
          rtsp_web_socket_uri: boolean(),
          receive_source: boolean(),
          media_profile_source: boolean(),
          dynamic_recordings: boolean(),
          dynamic_tracks: boolean(),
          max_string_length: integer()
        }

  @doc """
  Converts a parsed map into a %Onvif.Replay.ServiceCapabilities{} struct with validated types.
  """
  def from_parsed(parsed) do
    # Ensure only valid keys and convert values
    converted =
      @fields
      |> Enum.map(fn {key, _default} -> {key, convert_value(key, Map.get(parsed, key))} end)
      |> Enum.into(%{})

    struct(__MODULE__, converted)
  end

  defp convert_value(_key, "true"), do: true
  defp convert_value(_key, "false"), do: false
  defp convert_value(_key, nil), do: nil
  defp convert_value(_key, value), do: value
end
