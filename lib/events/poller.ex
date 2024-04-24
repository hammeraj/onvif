defmodule Onvif.Events.Poller do
  use GenServer

  require Logger

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def init(device) do
    Process.send_after(self(), :poll, 10000)

    {:ok, subscription} = Onvif.Events.CreatePullPointSubscription.request(device)

    {:ok, %{device: device, subscription: subscription, current_events: %{}}}
  end

  def handle_info(:poll, %{device: device, subscription: subscription, current_events: current_events}) do
    messages = Onvif.Events.PullMessages.request(device, subscription.address)

    new_events = messages
    |> Enum.group_by(& &1.topic)
    |> Enum.map(fn {topic, events} ->
      max = Enum.max_by(events, & &1.utc_time)
      min = Enum.min_by(events, & &1.utc_time)

      [current_min, _current_max] = Map.get(current_events, topic, [nil, nil])

      new_current = if current_min, do: [current_min, max.utc_time], else: [min.utc_time, max.utc_time]

      {topic, new_current}
    end) |> Enum.into(%{})

    finished_topics = MapSet.difference(MapSet.new(Map.keys(current_events)), MapSet.new(Map.keys(new_events)))

    Enum.each(finished_topics, fn topic ->
      event = Map.get(current_events, topic)
      Logger.info("#{topic} : " <> inspect(event))
    end)

    Process.send_after(self(), :poll, 10000)

    {:noreply, %{device: device, subscription: subscription, current_events: new_events}}
  end
end
