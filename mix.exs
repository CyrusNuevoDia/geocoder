defmodule Geocoder.Mixfile do
  use Mix.Project

  @source_url "https://github.com/CyrusOfEden/geocoder"
  @version "2.2.2"

  def project do
    [
      app: :geocoder,
      version: @version,
      elixir: "~> 1.14",
      otp: "~> 24",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def package do
    [
      description: "A simple, efficient geocoder/reverse geocoder with a built-in cache.",
      licenses: ["MIT"],
      maintainers: ["Cyrus Nouroozi", "Arjan Scherpenisse", "Michael Bianco", "epinault"],
      links: %{
        "Changelog" => "https://github.com/CyrusNuevoDia/geocoder/releases",
        "GitHub" => @source_url
      }
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:httpoison, "~> 2.1", optional: true},
      {:jason, "~> 1.2", optional: true},
      {:jsx, "~> 2.8 or ~> 3.0", optional: true},
      {:towel, "~> 0.2.2"},
      {:poolboy, "~> 1.5"},
      {:geohash, "~> 1.2"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:hammox, "~> 0.7", only: :test},
      {:excoveralls, "~> 0.14", only: :test}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs do
    [
      extras: [
        "CODE_OF_CONDUCT.md": [title: "Code of Conduct"],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"],
        "CHANGELOG.md": [title: "Changelog"]
      ],
      groups_for_modules: [
        Providers: ~r/^Geocoder.Providers/,
        Structs: [Geocoder.Bounds, Geocoder.Coords, Geocoder.Location]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      homepage_url: @source_url,
      formatters: ["html"]
    ]
  end
end
