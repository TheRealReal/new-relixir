defmodule NewRelixir.Mixfile do
  use Mix.Project

  def project do
    [app: :new_relixir,
     name: "New Relixir",
     version: "0.0.1",
     elixir: "~> 1.1",
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
    [{:phoenix, "~> 1.1"},
     {:ecto, "~> 1.1"},
     {:newrelic, git: "https://github.com/wooga/newrelic-erlang.git"},
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.11", only: :dev}]
  end

  defp aliases do
    ["test": ["test --no-start"]]
  end
end
