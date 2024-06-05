defmodule Onvif.MixProject do
  use Mix.Project

  def project do
    [
      app: :onvif,
      version: "0.3.3",
      elixir: "~> 1.13",
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
      {:ecto, "~> 3.9"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:finch, "~> 0.16"},
      {:sweet_xml, "~> 0.7"},
      {:tesla, "~> 1.7"},
      {:xml_builder, "~> 2.1"},
      {:jason, "~> 1.4"},
      {:mimic, "~> 1.7", only: :test}
    ]
  end
end
