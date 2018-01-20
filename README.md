# New Relixir [![Build Status](https://travis-ci.org/TheRealReal/new-relixir.svg?branch=master)](https://travis-ci.org/TheRealReal/new-relixir)

Instrument your Phoenix and Plug applications with New Relic.

New Relixir currently supports instrumenting bare-bones Plug endpoints, Phoenix
controllers and Ecto repositories, to record response times of web transactions
and database queries.

* [Documentation](https://hexdocs.pm/new_relixir/)

## Usage

The following instructions show how to add instrumentation with New Relixir to a hypothetical
Phoenix application named `MyApp`.

1.  Add `new_relixir` to your list of dependencies and start-up applications in `mix.exs`:

    ```elixir
    # mix.exs

    defmodule MyApp.Mixfile do
      use Mix.Project

      # ...

      def application do
        [mod: {MyApp, []},
         applications: [:new_relixir]]
      end

      defp deps do
        [{:new_relixir, "~> 0.4.0"}]
      end
    end
    ```

2.  Add your New Relic application name and license key to `config/config.exs`. You may wish to use
    environment variables to keep production, staging, and development environments separate:

    ```elixir
    # config/config.exs

    config :new_relixir,
      application_name: System.get_env("NEWRELIC_APP_NAME"),
      license_key: System.get_env("NEWRELIC_LICENSE_KEY")
    ```

3.  Add `NewRelixir.Instrumenters.Phoenix` to the list of instrumenters in your `Endpoint`
    configuration:

    ```elixir
    # config/config.exs

    config :my_app, MyAppWeb.Endpoint,
      instrumenters: [NewRelixir.Instrumenters.Phoenix],
      # ...
    ```

4.  If your app also uses `Ecto`, define a module to wrap your repository's methods with
    New Relic instrumentation:

    ```elixir
    # lib/my_app/repo.ex

    defmodule MyApp.Repo do
      use Ecto.Repo, otp_app: :my_app

      defmodule NewRelic do
        use NewRelixir.Plug.Repo, repo: MyApp.Repo
      end
    end
    ```

    Now `MyApp.Repo.NewRelic` can be used as a substitute for `MyApp.Repo`. It will dispatch
    and instrument the response time for all `Repo` calls.

    If you've defined custom functions on your `Repo`, you will need to define them on your
    wrapper module as well. In the wrapper module, simply call your repository's original
    function inside a closure that you pass to `instrument_db`:

    ```elixir
    # lib/my_app/repo.ex

    defmodule MyApp.Repo do
      use Ecto.Repo, otp_app: :my_app

      def my_custom_operation(queryable, opts \\ []) do
        # ...
      end

      defmodule NewRelic do
        use NewRelixir.Plug.Repo, repo: MyApp.Repo

        def my_custom_operation(queryable, opts \\ []) do
          instrument_db(:my_custom_operation, queryable, opts, fn() ->
            MyApp.Repo.my_custom_operation(queryable, opts)
          end)
        end
      end
    end
    ```

    When using the wrapper module's `my_custom_operation`, the time it takes to call
    `MyApp.Repo.my_custom_operation/2` will be recorded to New Relic.

## Upgrading from 0.3.x

1.  Remove `NewRelixir.Plug.Phoenix` from your Plug pipeline and all further references to
    that module.

2.  Add `NewRelixir.Instrumenters.Phoenix` to the list of instrumenters in your `Endpoint`
    configuration. See more in [usage](#usage).

3.  Passing a `conn` to the functions of your `Repo` wrapper is no longer required, calls
    to the wrapper can now be made the same way as calls to the original `Repo`:

    ```elixir
    # web/controllers/users.ex

    defmodule MyApp.UserController do
      use MyApp.Web, :controller

      def index(conn, _params) do
        # Before
        users = Repo.all(User, conn: conn)

        # Now
        users = Repo.all(User)
      end
    end
    ```

## Copyright

Copyright &copy; 2016 The RealReal, Inc.

Distributed under the [MIT License](LICENSE).
