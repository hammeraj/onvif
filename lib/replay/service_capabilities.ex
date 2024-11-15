defmodule Onvif.Replay.ServiceCapabilities do
  @derive Jason.Encoder
  defstruct [:rtp_rtsp_tcp, :reverse_playback, :session_timeout_range, :rtsp_web_socket_uri]
end
