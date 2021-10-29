# OpentelemetrySnowpack

[![CI](https://github.com/HGInsights/opentelemetry_snowpack/workflows/CI/badge.svg)](https://github.com/HGInsights/opentelemetry_snowpack/actions/workflows/elixir.yml)

Telemetry handler that creates OpenTelemetry spans from [Snowpack](https://github.com/HGInsights/opentelemetry_snowpack)
(Snowflake) query events.

After installing, setup the handler in your application behaviour before your top-level supervisor starts.

```elixir
OpentelemetrySnowpack.setup()
```

See the [documentation](https://hginsights.github.io/opentelemetry_snowpack) for `OpentelemetrySnowpack`.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed by adding `opentelemetry_snowpack` to
your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:opentelemetry_snowpack, "~> 0.1.0"}
  ]
end
```

## Compatibility Matrix

| OpentelemetrySnowpack Version | Otel Version | Notes |
| :---------------------------- | :----------- | :---- |
|                               |              |       |
| v0.1.0                        | v1.0.0-rc.3  |       |

## Contributing

Run tests:

```
git clone git@github.com:HGInsights/opentelemetry_snowpack.git
cd opentelemetry_snowpack
mix deps.get
mix test
```

Working with [Earthly](https://earthly.dev/) for CI

```
brew install earthly

earthly +static-code-analysis

earthly --secret SNOWPACK_SERVER="my-account.snowflakecomputing.com" --secret-file SNOWPACK_PRIV_KEY=./rsa_key.p8 +test
```

## License

The source code is under Apache License 2.0.

Copyright (c) 2021 HG Insights

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific
language governing permissions and limitations under the License.
