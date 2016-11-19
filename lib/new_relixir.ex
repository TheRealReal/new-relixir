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
      worker(:statman_server, [1000]),
      worker(:statman_aggregator, []),
    ]

    opts = [strategy: :one_for_one, name: NewRelixir.Supervisor]
    result = Supervisor.start_link(children, opts)

    :ok = :statman_server.add_subscriber(:statman_aggregator)

    with app_name    <- Application.get_env(:new_relixir, :application_name),
         license_key <- Application.get_env(:new_relixir, :license_key),
         true        <- String.valid?(app_name),
         true        <- String.valid?(license_key) do
      Application.put_env(:newrelic, :application_name, to_char_list(app_name))
      Application.put_env(:newrelic, :license_key, to_char_list(license_key))

      {:ok, _} = :newrelic_poller.start_link(&:newrelic_statman.poll/0)
    end

    result
  end

  @doc false
  @spec configured? :: boolean
  def configured? do
    Application.get_env(:new_relixir, :application_name) != nil && Application.get_env(:new_relixir, :license_key) != nil
  end
end
