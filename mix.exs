defmodule Onvif.MixProject do
  use Mix.Project

  @github_url "https://github.com/hammeraj/onvif"

  def project do
    [
      app: :onvif,
      version: "0.5.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # ex_doc / hex
      name: "Onvif",
      source_url: @github_url,
      description: "Elixir interface for Onvif functions",
      docs: docs(),
      package: [
        licenses: ["BSD-3-Clause"],
        links: %{
          "GitHub" => @github_url
        }
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Onvif.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.12"},
      {:ex_doc, "~> 0.36", only: :dev, runtime: false},
      {:finch, "~> 0.19"},
      {:sweet_xml, "~> 0.7"},
      {:tesla, "~> 1.13"},
      {:xml_builder, "~> 2.3"},
      {:jason, "~> 1.4"},
      {:mimic, "~> 1.7.4", only: :test}
    ]
  end

  defp docs do
    [
      main: "Onvif",
      extras: ["README.md"],
      nest_modules_by_prefix: [
        Onvif.Device,
        Onvif.Schemas,
        Onvif.Devices,
        Onvif.Devices.Schemas,
        Onvif.Media.Ver10,
        Onvif.Media.Ver10.Schemas,
        Onvif.Media.Ver20,
        Onvif.Media.Ver20.Schemas,
        Onvif.Recording,
        Onvif.Recording.Schemas,
        Onvif.Replay,
        Onvif.Replay.Schemas,
        Onvif.Search,
        Onvif.Search.Schemas,
        Onvif.PTZ,
        Onvif.PTZ.Schemas
      ],
      groups_for_modules: [
        Core: [
          Onvif,
          ~r/^Onvif.Discovery.*/,
          Onvif.Device,
          Onvif.MacAddress,
          Onvif.Request,
          ~r/Onvif.Schemas.*/
        ],
        "Device Management": [
          ~r/^Onvif.Devices.*/
        ],
        Media10: [
          ~r/^Onvif.Media.Ver10.*/
        ],
        Media20: [
          ~r/^Onvif.Media.Ver20.*/
        ],
        Recording: [
          ~r/^Onvif.Recording.*/
        ],
        Replay: [
          ~r/^Onvif.Replay.*/
        ],
        Search: [
          ~r/^Onvif.Search.*/
        ],
        PTZ: [
          ~r/^Onvif.PTZ.*/
        ]
      ]
    ]
  end
end
