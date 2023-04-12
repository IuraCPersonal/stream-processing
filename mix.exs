defmodule PtrProject1Enhanced.MixProject do
  use Mix.Project

  def project do
    [
      app: :build,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:httpoison],
      extra_applications: [:logger, :poison, :jason],
      mod: {PtrProject1Enhanced.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  # Run "mix deps.get" to install all dependencies. 👈
  defp deps do
    [
      {:httpoison, "~> 2.0"},
      {:json, "~> 1.4"},
      {:poison, "~> 5.0"},
      {:jason, "~> 1.3"}
    ]
  end
end
