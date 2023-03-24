defmodule Onvif.Middleware.DigestAuth do
  @moduledoc """
  This is a direct fork of the `Tesla.Middleware.DigestAuth`, which, does not build the
  [digest-response](https://datatracker.ietf.org/doc/html/rfc2617#section-3.2.2) in the order that
  the UniView LAPI accepts/understands.
  """

  @behaviour Tesla.Middleware

  import XmlBuilder

  @standard_namespaces [
    "xmlns:s": "http://www.w3.org/2003/05/soap-envelope"
  ]

  @impl Tesla.Middleware
  def call(env, next, opts) do
    if env.opts && Keyword.get(env.opts, :digest_auth_handshake) do
      Tesla.run(env, next)
    else
      body =
        generate(
          element(:"s:Envelope", @standard_namespaces ++ env.body.namespaces, [env.body.content])
        )

      env = env |> Tesla.put_body(body)

      with {:ok, headers} <- authorization_header(env, opts) do
        env |> Tesla.put_headers(headers) |> Tesla.run(next)
      end
    end
  end

  defp authorization_header(env, opts) do
    with {:ok, vars} <- authorization_vars(env, opts) do
      {:ok, vars |> calculated_authorization_values() |> create_header()}
    end
  end

  defp authorization_vars(env, opts) do
    with {:ok, unauthorized_response} <-
           env.__module__.request(
             env.__client__,
             method: env.opts[:pre_auth_method] || env.method,
             url: env.url,
             opts: Keyword.put(env.opts, :digest_auth_handshake, true),
             headers: env.headers,
             body: env.body
           ) do
      {:ok,
       %{
         username: opts[:username] || "",
         password: opts[:password] || "",
         path: URI.parse(env.url).path,
         auth:
           unauthorized_response
           |> Tesla.get_header("www-authenticate")
           |> parse_www_authenticate_header(),
         method: env.method |> to_string() |> String.upcase(),
         client_nonce: (opts[:cnonce_fn] || (&cnonce/0)).(),
         nc: opts[:nc] || "00000000"
       }}
    end
  end

  defp calculated_authorization_values(%{auth: auth}) when auth == %{}, do: []

  defp calculated_authorization_values(auth_vars) do
    # NOTE: the order of these key-value pairs DOES MATTER
    [
      {"response", response(auth_vars)},
      {"cnonce", auth_vars.client_nonce},
      {"nc", auth_vars.nc},
      {"qop", "auth"},
      {"algorithm", "MD5"},
      {"uri", auth_vars[:path]},
      {"nonce", auth_vars.auth["nonce"]},
      {"realm", auth_vars.auth["realm"]},
      {"username", auth_vars.username}
    ]
  end

  defp single_header_val({k, v}) when k in ~w(nc qop algorithm), do: "#{k}=#{v}"
  defp single_header_val({k, v}), do: "#{k}=\"#{v}\""

  defp create_header([]), do: []

  defp create_header(calculated_authorization_values) do
    vals =
      calculated_authorization_values
      |> Enum.reduce([], fn val, acc -> [single_header_val(val) | acc] end)
      |> Enum.join(", ")

    [{"authorization", "Digest #{vals}"}]
  end

  defp ha1(%{username: username, auth: %{"realm" => realm}, password: password}) do
    md5("#{username}:#{realm}:#{password}")
  end

  defp ha2(%{method: method, path: path}),
    do: md5("#{method}:#{path}")

  defp response(%{auth: %{"nonce" => nonce}, nc: nc, client_nonce: client_nonce} = auth_vars),
    do: md5("#{ha1(auth_vars)}:#{nonce}:#{nc}:#{client_nonce}:auth:#{ha2(auth_vars)}")

  defp parse_www_authenticate_header(nil), do: %{}

  defp parse_www_authenticate_header(header) do
    ~r/(\w+?)="(.+?)"/
    |> Regex.scan(header)
    |> Enum.reduce(%{}, fn [_, key, val], acc -> Map.merge(acc, %{key => val}) end)
  end

  defp md5(data), do: data |> :erlang.md5() |> Base.encode16(case: :lower)

  defp cnonce, do: :crypto.strong_rand_bytes(4) |> Base.encode16(case: :lower)
end
