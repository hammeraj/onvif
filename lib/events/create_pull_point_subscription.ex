defmodule Onvif.Events.CreatePullPointSubscription do
  import SweetXml
  import XmlBuilder

  alias Onvif.Device
  alias Onvif.Events.PullPointSubscription

  def soap_action,
    do: "http://www.onvif.org/ver10/events/wsdl/EventPortType/CreatePullPointSubscriptionRequest"

  @spec request(Device.t()) :: {:ok, any} | {:error, map()}
  def request(device), do: Onvif.Events.request(device, __MODULE__)

  def request_body do
    element(:"s:Body", [
      element(:"tev:CreatePullPointSubscription", [
        element(
          :Filter,
          %{"Dialect" => "http://www.onvif.org/ver10/tev/topicExpression/ConcreteSet"},
          "tns1:RuleEngine/CellMotionDetector/Motion"
        ),
        element(:InitialTerminationTime, "PT5M"),
        element(:"wsnt:SubscriptionPolicy", [element(:"wsnt:ChangedOnly", true), element(:"wsnt:UseRaw", true)])
      ])
    ])
  end

  def response(xml_response_body) do
    xml_response_body
    |> parse(namespace_conformant: true, quiet: true)
    |> xpath(
      ~x"//s:Envelope/s:Body/tev:CreatePullPointSubscriptionResponse"e
      |> add_namespace("s", "http://www.w3.org/2003/05/soap-envelope")
      |> add_namespace("tev", "http://www.onvif.org/ver10/events/wsdl")
      |> add_namespace("wsa", "http://www.w3.org/2005/08/addressing")
      |> add_namespace("wsnt", "http://docs.oasis-open.org/wsn/b-2")
    )
    |> PullPointSubscription.parse()
    |> PullPointSubscription.to_struct()
  end
end
