defmodule Onvif.MacAddress do
  @mac_with_colons_regex ~r/^(?:[[:xdigit:]]{2}(:))(?:[[:xdigit:]]{2}\1){4}[[:xdigit:]]{2}$/
  @mac_with_dashes_regex ~r/^(?:[[:xdigit:]]{2}(-))(?:[[:xdigit:]]{2}\1){4}[[:xdigit:]]{2}$/
  @mac_regex ~r/^(?:[[:xdigit:]]{12})$/

  def mac_with_colons(mac_address) do
    cond do
      Regex.match?(@mac_with_colons_regex, mac_address) ->
        {:ok, String.downcase(mac_address)}

      Regex.match?(@mac_with_dashes_regex, mac_address) ->
        {:ok, mac_address |> String.replace("-", ":") |> String.downcase()}

      Regex.match?(@mac_regex, mac_address) ->
        {:ok,
         mac_address
         |> String.split("", trim: true)
         |> Enum.chunk_every(2)
         |> Enum.join(":")
         |> String.downcase()}

      true ->
        {:error, :invalid_mac}
    end
  end

  def mac_just_digits(mac_address) do
    cond do
      Regex.match?(@mac_with_colons_regex, mac_address) ->
        {:ok, mac_address |> String.replace(":", "") |> String.downcase()}

      Regex.match?(@mac_with_dashes_regex, mac_address) ->
        {:ok, mac_address |> String.replace("-", "") |> String.downcase()}

      Regex.match?(@mac_regex, mac_address) ->
        {:ok, String.downcase(mac_address)}

      true ->
        {:error, :invalid_mac}
    end
  end
end
