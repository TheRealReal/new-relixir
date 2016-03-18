defmodule NewRelixir.Mixfile do
  use Mix.Project

  def project do
    [app: :new_relixir,
     version: "0.0.1",
     elixir: "~> 1.1",
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
     {:newrelic, git: "https://github.com/wooga/newrelic-erlang.git"}]
  end

  defp aliases do
    ["test": ["test --no-start"]]
  end
end
