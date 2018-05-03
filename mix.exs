defmodule NewRelixir.Mixfile do
  use Mix.Project

  def project do
    [
      app: :new_relixir,
      name: "New Relixir",
      version: "0.4.4",
      elixir: "~> 1.5",
      description: "New Relic tracking for Phoenix and Plug applications.",
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
      {:ex_doc, "~> 0.16", only: :dev},
      {:hackney, "~> 1.12"},
      {:phoenix, "~> 1.3", runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Fredrik Björk", "Robert Zotter", "Coburn Berry"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/TheRealReal/new-relixir"}
    ]
  end

  defp aliases do
    ["test": ["test --no-start"]]
  end
end
