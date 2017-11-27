defmodule NewRelixir do
  @moduledoc """
  Entry point for New Relixir OTP application.
  """

  use Application

  @doc """
  Application callback to start New Relixir.
  """
  @spec start(Application.app, Application.start_type) :: :ok | {:error, term}
  def start(_type \\ :normal, _args \\ []) do
    import Supervisor.Spec, warn: false

    children = [
      worker(NewRelixir.Collector, []),
      worker(NewRelixir.Poller, [&NewRelixir.Statman.poll/0])
    ]

    opts = [strategy: :one_for_one, name: NewRelixir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc false
  @spec configured? :: boolean
  def configured? do
    Application.get_env(:new_relixir, :application_name) != nil && Application.get_env(:new_relixir, :license_key) != nil
  end
end
