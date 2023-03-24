defmodule Onvif.Application do
  use Application
  @moduledoc false

  @impl true
  @spec start(atom(), keyword()) :: {:ok, pid()} | {:error, any()}
  def start(_type, _args) do
    children = [
      {Finch,
       name: Onvif.Finch,
       pools: %{
         :default => [size: 10]
       }}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
