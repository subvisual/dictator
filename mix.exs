defmodule Dictator.MixProject do
  use Mix.Project

  @version "1.0.0"

  def project do
    [
      app: :dictator,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      package: package(),
      docs: docs(),
      deps: deps(),
      name: "Dictator",
      source_url: "https://github.com/subvisual/dictator",
      dialyzer: [
        plt_add_apps: [:mix, :ex_unit],
        ignore_warnings: ".dialyzer_ignore.exs"
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:plug, "~> 1.8"},
      {:ecto, ">= 3.0.0", optional: true},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 1.2", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0", only: [:dev], runtime: false}
    ]
  end

  defp description do
    "Plug-based authorization for your web apps. Dictate what your users can and cannot see and access."
  end

  defp package do
    [
      licenses: ["ISC"],
      links: %{"GitHub" => "https://github.com/subvisual/dictator"},
      files: ~w(.formatter.exs mix.exs README.md lib LICENSE)
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_url: "https://github.com/subvisual/dictator",
      source_ref: "v#{@version}"
    ]
  end
end
