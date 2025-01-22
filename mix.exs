defmodule Onvif.MixProject do
  use Mix.Project

  def project do
    [
      app: :onvif,
      version: "0.5.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # ex_doc / hex
      name: "Onvif",
      source_url: "https://github.com/hammeraj/onvif",
      description: "Elixir interface for Onvif functions",
      docs: [
        # The main page in the docs
        main: "Onvif",
        extras: ["README.md"]
      ],
      package: [
        licenses: ["BSD-3-Clause"],
        links: []
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
end
