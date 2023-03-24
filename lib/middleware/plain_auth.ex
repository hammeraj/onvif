defmodule Onvif.Middleware.PlainAuth do
  @moduledoc """
  """

  @behaviour Tesla.Middleware
  import XmlBuilder

  @security_header_namespaces [
    "xmlns:wsse":
      "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext1.0.xsd"
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
    case generate_xml_auth_header(opts) do
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

  defp generate_xml_auth_header(username: username, password: password)
       when is_binary(username) and is_binary(password) do
    element(
      :"s:Header",
      [
        element(
          :"wsse:Security",
          [
            element(
              :"wsse:UsernameToken",
              [
                element(:"wsse:Username", username),
                element(
                  :"wsse:Password",
                  %{
                    "Type" =>
                      "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText"
                  },
                  password
                )
              ]
            )
          ]
        )
      ]
    )
  end

  defp generate_xml_auth_header(_uri), do: nil
end
