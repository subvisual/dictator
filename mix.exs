defmodule Dictator.MixProject do
  use Mix.Project

  @env Mix.env()

  def project do
    [
      app: :dictator,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      package: package(),
      deps: deps(),
      name: "Dictator",
      source_url: "https://github.com/subvisual/dictator",
      dialyzer: [
        plt_add_apps: [:mix, :ex_unit],
        ignore_warnings: ".dialyzer_ignore.exs",
        flags: [:underspecs, :race_conditions]
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
      {:plug, "~> 1.8"}
      | deps(@env)
    ]
  end

  defp deps(env) when env in [:dev, :test] do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 1.2", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0", only: [:dev], runtime: false}
    ]
  end

  defp deps(_env), do: []

  defp description do
    "Plug-based authorization for your web apps. Dictate what your users can and cannot see and access."
  end

  defp package do
    [
      licenses: ["ISC"],
      links: %{"GitHub" => "https://github.com/subvisual/dictator"}
    ]
  end
end
