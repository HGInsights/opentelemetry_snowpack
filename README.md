# OpentelemetrySnowpack

[![CI](https://github.com/HGInsights/opentelemetry_snowpack/actions/workflows/elixir-ci.yml/badge.svg)](https://github.com/HGInsights/opentelemetry_snowpack/actions/workflows/elixir-ci.yml)
[![hex.pm version](https://img.shields.io/hexpm/v/opentelemetry_snowpack.svg)](https://hex.pm/packages/opentelemetry_snowpack)
[![hex.pm license](https://img.shields.io/hexpm/l/opentelemetry_snowpack.svg)](https://github.com/HGInsights/opentelemetry_snowpack/blob/main/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/HGInsights/opentelemetry_snowpack.svg)](https://github.com/HGInsights/opentelemetry_snowpack/commits/main)

<!-- MDOC !-->

  `OpentelemetrySnowpack` uses Elixir [telemetry](https://hexdocs.pm/telemetry/) handlers to create [OpenTelemetry](https://opentelemetry.io/) spans from [Snowpack](https://github.com/HGInsights/snowpack)
(Snowflake driver) query events.

  Currently it supports Snowpack query events: start, stop, exception.

## Usage

Add `:opentelemetry_snowpack` to your dependencies:

```elixir
def deps() do
  [
    {:snowpack, "~> 0.6.0"},
    {:opentelemetry_snowpack, "~> 0.1.0"}
  ]
end
```

Make sure you are using the latest version!

In your application start:

```elixir
def start(_type, _args) do
  OpentelemetrySnowpack.setup()

  # ...
end
```

<!-- MDOC !-->



## Documentation

Documentation is automatically published to
[hexdocs.pm](https://hexdocs.pm/opentelemetry_snowpack) on release. You may build the
documentation locally with

```
MIX_ENV=docs mix docs
```

## Contributing

Issues and PRs are welcome! See our organization [CONTRIBUTING.md](https://github.com/HGInsights/.github/blob/main/CONTRIBUTING.md) for more information about best-practices and passing CI.
