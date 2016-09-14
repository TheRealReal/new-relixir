defmodule NewRelixir.Mixfile do
  use Mix.Project

  def project do
    [app: :new_relixir,
     name: "New Relixir",
     version: "0.1.0",
     elixir: "~> 1.1",
     description: "New Relic tracking for Elixir applications.",
     package: package,
     source_url: "https://github.com/TheRealReal/new-relixir",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  def application do
    [mod: {NewRelixir, []},
     applications: [:logger, :lhttpc]]
  end

  defp deps do
    [{:phoenix, "~> 1.2"},
     {:ecto, "~> 2.0"},
     {:newrelic, "~> 0.1.0"},
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.11", only: :dev}]
  end

  defp package do
    [maintainers: ["David Cuddeback"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/TheRealReal/new-relixir"}]
  end

  defp aliases do
    ["test": ["test --no-start"]]
  end
end
