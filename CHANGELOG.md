# Version 0.4.8
* Fix @SPEC for Repo.insert_all/3 (#56)(https://github.com/TheRealReal/new-relixir/pull/58)
* Update repo transaction spec to match the callback from Ecto (#60)(https://github.com/TheRealReal/new-relixir/pull/60)
* Allowing instrumentation of Ecto.Adapters.SQL.query (#63)(https://github.com/TheRealReal/new-relixir/pull/63)

# Version 0.4.7
* Support registered processes as ancestors [#58](https://github.com/TheRealReal/new-relixir/pull/58)

# Version 0.4.6
* Fixes undefined function [`NewRelixir.Collector.start_link/0`](https://github.com/TheRealReal/new-relixir/issues/54)

# Version 0.4.5
* Fixes dialyzer errors [#53](https://github.com/TheRealReal/new-relixir/pull/53)
* Adjust instruction for Elixir version >= 1.4 [#52](https://github.com/TheRealReal/new-relixir/pull/53)
* Resolve default init warning #48 [#48](https://github.com/TheRealReal/new-relixir/issues/48)

# Version 0.4.4
* Use dyno name as hostname for heroku users [#47](https://github.com/TheRealReal/new-relixir/pull/47)

# Version 0.4.3
* Add stack trace to error reporting and add plug error handler [#46](https://github.com/TheRealReal/new-relixir/pull/46)
* Update hackney dependency [commit](https://github.com/TheRealReal/new-relixir/commit/0c5ca9469f1c9a4d0c1b2d44b75c4d439c28cedf)

# Version 0.4.2
* Fix polling and language setting config keys  [#43](https://github.com/TheRealReal/new-relixir/pull/43)
* Fix test race condition  [#42](https://github.com/TheRealReal/new-relixir/pull/42)
* Fix Dialyzer types  [#41](https://github.com/TheRealReal/new-relixir/pull/41)

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
