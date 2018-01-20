# Version 0.4.1
* Fix Ecto.Repo.transaction arguments [#35](https://github.com/TheRealReal/new-relixir/pull/37)

# Version 0.4.0

*  Support Phoenix built-in instrumentation [#31](https://github.com/TheRealReal/new-relixir/pull/31)
*  Support for Plug-only, non-Phoenix applications [#31](https://github.com/TheRealReal/new-relixir/pull/31)
*  Deprecate `NewRelixir.Plug.Phoenix` [#31](https://github.com/TheRealReal/new-relixir/pull/31)
*  Remove statman and newrelic dependencies ( replace with Agent ) [#24](https://github.com/TheRealReal/new-relixir/pull/24)
*  Replace lhttpc with hackney [#24](https://github.com/TheRealReal/new-relixir/pull/24)
*  Support Repo.aggregate/4 instrumentation [#22](https://github.com/TheRealReal/new-relixir/commit/dc178ef3c84671b5c06b204b912f9c82968ab33c)
*  Support insert_all/3 [#32](https://github.com/TheRealReal/new-relixir/pull/32)
*  Fix preload with multiple structs by inferring name from first entry [#33](https://github.com/TheRealReal/new-relixir/pull/33)
*  Update Ecto dependency to ~> 2.0
*  Update Elixir dependency to ~> 1.5
*  Update Phoenix dependency to ~> 1.3
