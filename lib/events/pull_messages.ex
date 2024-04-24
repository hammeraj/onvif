defmodule Onvif.Events.PullMessages do
  import SweetXml
  import XmlBuilder

  alias Onvif.Device

  require Logger

  def soap_action,
    do: "http://www.onvif.org/ver10/events/wsdl/PullPointSubscription/PullMessagesRequest"

  @spec request(Device.t(), String.t()) :: {:ok, any} | {:error, map()}
  def request(device, endpoint),
    do: Onvif.Events.request(device, [endpoint: endpoint], __MODULE__)

  def request_body do
    element(:"s:Body", [
      element(:"tev:PullMessages", [
        element(:"tev:Timeout", "PT0,05S"),
        element(:"tev:MessageLimit", 100)
      ])
    ])
  end

  def response(xml_response_body) do
    xml_response_body
      |> parse(namespace_conformant: true, quiet: true)
      |> xpath(
        ~x"//s:Envelope/s:Body/tev:PullMessagesResponse/wsnt:NotificationMessage"el
        |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
        |> add_namespace("tev", "http://www.onvif.org/ver10/events/wsdl")
        |> add_namespace("wsnt", "http://docs.oasis-open.org/wsn/b-2")
        |> add_namespace("tt", "http://www.onvif.org/ver10/schema")
      )
      |> Enum.map(&Onvif.Events.Message.parse/1)
      |> Enum.reduce([], fn raw_message, acc ->
        case Onvif.Events.Message.to_struct(raw_message) do
          {:ok, message} ->
            [message | acc]

          {:error, changeset} ->
            Logger.error("Discarding invalid message: #{inspect(changeset)}")
            acc
        end
      end)
  end
end
