defmodule Onvif.Middleware.NoAuth do
  @moduledoc false

  @behaviour Tesla.Middleware
  import XmlBuilder

  @standard_namespaces [
    "xmlns:s": "http://www.w3.org/2003/05/soap-envelope"
  ]

  @impl Tesla.Middleware
  def call(env, next, _opts) do
    body =
      generate(
        element(:"s:Envelope", @standard_namespaces ++ env.body.namespaces, [env.body.content])
      )

    env |> Tesla.put_body(body) |> Tesla.run(next)
  end
end
