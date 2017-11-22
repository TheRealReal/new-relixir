defmodule NewRelixir.Mixfile do
  use Mix.Project

  def project do
    [app: :new_relixir,
     name: "New Relixir",
     version: "0.3.0-rc.0",
     elixir: "~> 1.2",
     description: "New Relic tracking for Elixir applications.",
     package: package(),
     source_url: "https://github.com/TheRealReal/new-relixir",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [mod: {NewRelixir, []},
     applications: [:logger, :lhttpc]]
  end

  defp deps do
    [
      {:earmark, "~> 0.1", only: :dev},
      {:ecto, ">= 1.1.0 and < 3.0.0"},
      {:ex_doc, "~> 0.11", only: :dev},
      {:lhttpc, "~> 1.4"},
      {:phoenix, "~> 1.3"}
    ]
  end

  defp package do
    [maintainers: ["Fredrik Björk", "Robert Zotter"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/TheRealReal/new-relixir"}]
  end
end
