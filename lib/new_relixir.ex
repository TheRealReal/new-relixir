defmodule NewRelixir do
  @moduledoc """
  Entry point for New Relixir OTP application.
  """

  use Application

  require Logger

  @doc """
  Application callback to start New Relixir.
  """
  @spec start(Application.app, Application.start_type) :: :ok | {:error, term}
  def start(_type \\ :normal, _args \\ []) do
    import Supervisor.Spec, warn: false

    check_config()

    children = [
      worker(NewRelixir.Collector, []),
      worker(NewRelixir.Polling, [&NewRelixir.Stats.pull/0])
    ]

    opts = [strategy: :one_for_one, name: NewRelixir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Tells if New Relixir is configured correctly and pushing data to New Relic.
  """
  @spec active? :: boolean
  def active? do
    Application.get_env(:new_relixir, :active)
  end

  defp check_config do
    application_name = Application.get_env(:new_relixir, :application_name)
    license_key = Application.get_env(:new_relixir, :license_key)
    valid_config = String.valid?(application_name) && String.valid?(license_key)

    if valid_config, do: Logger.info fn ->
      "New Relixir set up for '#{application_name}'."
    end

    Application.put_env(:new_relixir, :active, valid_config)
  end
end
