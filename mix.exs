defmodule NewRelixir.Mixfile do
  use Mix.Project

  def project do
    [
      app: :new_relixir,
      name: "New Relixir",
      version: "0.4.0",
      elixir: "~> 1.5",
      description: "New Relic tracking for Elixir applications.",
      package: package(),
      source_url: "https://github.com/TheRealReal/new-relixir",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {NewRelixir.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto, "~> 2.0", runtime: false},
      {:ex_doc, "~> 0.16", only: :docs},
      {:hackney, "~> 1.10"},
      {:phoenix, "~> 1.3", runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Fredrik Björk", "Robert Zotter"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/TheRealReal/new-relixir"}
    ]
  end

  defp aliases do
    ["test": ["test --no-start"]]
  end
end
