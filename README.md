# New Relixir

Instrument your Phoenix applications with New Relic.

New Relixir currently supports instrumenting Phoenix controllers and Ecto repositories to record
response times for web transactions and database queries.

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
        [{:new_relixir, "~> 0.2.1"}]
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


3.  Define a module to wrap your repository's methods with New Relic instrumentation:

    ```elixir
    # lib/my_app/repo.ex

    defmodule MyApp.Repo do
      use Ecto.Repo, otp_app: :my_app

      defmodule NewRelic do
        use NewRelixir.Plug.Repo, repo: MyApp.Repo
      end
    end
    ```

    Now `MyApp.Repo.NewRelic` can be used as a substitute for `MyApp.Repo`. If a `Plug.Conn` is
    provided as the `:conn` option to any of the wrapper's methods, it will instrument the response
    time for that call. Otherwise, the repository will behave the same as the repository that it
    wraps.

4.  For any Phoenix controller that you want to instrument, add `NewRelixir.Plug.Phoenix` and
    replace existing aliases to your application's repository with an alias to your New Relic
    repository wrapper. If instrumenting all controllers, update `web/web.ex`:

    ```elixir
    # web/web.ex

    defmodule MyApp.Web do
      def controller do
        quote do
          # ...
          plug NewRelixir.Plug.Phoenix
          alias MyApp.Repo.NewRelic, as: Repo # Replaces `alias MyApp.Repo`
        end
      end
    end
    ```

5.  Update your controllers to pass `conn` as an option to your New Relic repo wrapper:

    ```elixir
    # web/controllers/users.ex

    defmodule MyApp.UserController do
      use MyApp.Web, :controller

      def index(conn, _params) do
        users = Repo.all(User, conn: conn) # Replaces `Repo.all(User)`
        # ...
      end
    end
    ```

### Instrumenting Custom Repo Methods

If you've defined custom methods on your repository, you will need to define them on your wrapper
module as well. In the wrapper module, simply call your repository's original method inside a
closure that you pass to `instrument_db`:

```elixir
# lib/my_app/repo.ex

defmodule MyApp.Repo do
  use Ecto.Repo, otp_app: :my_app

  def custom_method(queryable, opts \\ []) do
    # ...
  end

  defmodule NewRelic do
    use NewRelixir.Plug.Repo, repo: MyApp.Repo

    def custom_method(queryable, opts \\ []) do
      instrument_db(:custom_method, queryable, opts, fn() ->
        MyApp.Repo.custom_method(queryable, opts)
      end)
    end
  end
end
```

When using the wrapper module's `custom_method`, the time it takes to call
`MyApp.Repo.custom_method/2` will be recorded to New Relic.

## Copyright

Copyright &copy; 2016 The RealReal, Inc.

Distributed under the [MIT License](LICENSE).
