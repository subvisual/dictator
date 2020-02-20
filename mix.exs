defmodule Dictator.MixProject do
  use Mix.Project

  @env Mix.env()

  def project do
    [
      app: :dictator,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.8"}
      | deps(@env)
    ]
  end

  defp deps(env) when env in [:dev, :test] do
    [
      {:credo, "~> 1.2", runtime: false}
    ]
  end

  defp deps(_env), do: []
end
