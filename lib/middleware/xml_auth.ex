defmodule Onvif.Middleware.XmlAuth do
  @moduledoc """
  """

  @behaviour Tesla.Middleware
  import XmlBuilder

  @nonce_bytesize 16

  @security_header_namespaces [
    "xmlns:wsse":
      "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd",
    "xmlns:wsu":
      "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"
  ]

  @standard_namespaces [
    "xmlns:s": "http://www.w3.org/2003/05/soap-envelope"
  ]

  @impl Tesla.Middleware
  def call(env, next, opts) do
    body = inject_xml_auth_header(env, opts)
    env |> Tesla.put_body(body) |> Tesla.run(next)
  end

  defp inject_xml_auth_header(env, opts) do
    case generate_xml_auth_header(env.url, opts) do
      nil ->
        generate(
          element(:"s:Envelope", @standard_namespaces ++ env.body.namespaces, [env.body.content])
        )

      auth_header ->
        generate(
          element(
            :"s:Envelope",
            @standard_namespaces ++ @security_header_namespaces ++ env.body.namespaces,
            [auth_header, env.body.content]
          )
        )
    end
  end

  defp generate_xml_auth_header(url, username: username, password: password)
       when is_binary(username) and is_binary(password) do
    uri = URI.parse(url)
    {:ok, system_date} = %URI{uri | userinfo: "", path: ""} |> URI.to_string() |> Onvif.Devices.GetSystemDateAndTime.request()
    created_at = DateTime.utc_now() |> DateTime.add(system_date.current_diff) |> DateTime.to_iso8601()
    nonce_bytes = :rand.bytes(@nonce_bytesize)
    nonce = Base.encode64(nonce_bytes)
    digest = :sha |> :crypto.hash(nonce_bytes <> created_at <> password) |> Base.encode64()

    element(
      :"s:Header",
      [
        element(
          :"wsse:Security", %{"s:mustUnderstand" => "1"},
          [
            element(
              :"UsernameToken",
              [
                element(:"Username", username),
                element(
                  :"Password",
                  %{
                    "Type" =>
                      "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest"
                  },
                  digest
                ),
                element(
                  :"Nonce",
                  %{
                    "EncodingType" =>
                      "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary"
                  },
                  nonce
                ),
                element(:"wsu:Created", created_at)
              ]
            )
          ]
        )
      ]
    )
  end

  defp generate_xml_auth_header(_uri, _opt), do: nil
end
