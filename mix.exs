defmodule Loggee.MixProject do
  use Mix.Project

  def project do
    [
      app: :loggee,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      escript: escript(),
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  def escript do
    [main_module: Loggee.Cli]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Loggee.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:ex_gram, "~> 0.21"},
      {:tesla, "~> 1.4.0"},
    # optional, but recommended adapter
      {:hackney, "~> 1.16.0"},
    # optional, required by JSON middleware
      {:jason, ">= 1.0.0"},
      {:sweet_xml, ">= 0.3.0"}
    ]
  end

  defp description do
    "A tool to interact with your board game collection and plays in Board Game Geek"
  end

  defp package do
    [
      name: "bgg_loggee",
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/gionaufal/loggee"}
    ]
  end
end
