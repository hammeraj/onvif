defmodule Onvif.API do
  @moduledoc false

  @spec client(String.t(), :no_auth | :basic_auth | :xml_auth | :digest_auth) :: Tesla.Client.t()
  def client(uri, auth \\ :xml_auth) do
    adapter = {Tesla.Adapter.Finch, name: Onvif.Finch}
    parsed_uri = URI.parse(uri)
    no_userinfo_uri = %URI{parsed_uri | userinfo: nil} |> URI.to_string()

    middleware = [
      {Tesla.Middleware.BaseUrl, no_userinfo_uri},
      auth_function(auth, parsed_uri),
      {Tesla.Middleware.Logger, log_level: :info},
      {Tesla.Middleware.Headers,
       [
         {"connection", "keep-alive"}
       ]}
    ]

    Tesla.client(middleware, adapter)
  end

  defp auth_function(:no_auth, _), do: Onvif.Middleware.NoAuth
  defp auth_function(:basic_auth, %URI{} = uri), do: {Onvif.Middleware.PlainAuth, get_auth(uri)}
  defp auth_function(:xml_auth, %URI{} = uri), do: {Onvif.Middleware.XmlAuth, get_auth(uri)}
  defp auth_function(:digest_auth, %URI{} = uri), do: {Onvif.Middleware.DigestAuth, get_auth(uri)}

  @spec get_auth(URI.t()) :: keyword()
  defp get_auth(%URI{userinfo: userinfo}) when is_binary(userinfo) do
    [username, password] = String.split(userinfo, ":", parts: 2)
    [username: URI.decode_www_form(username), password: URI.decode_www_form(password)]
  end

  defp get_auth(_uri), do: [username: nil, password: nil]
end
