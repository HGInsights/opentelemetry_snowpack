# OpentelemetrySnowpack

Telemetry handler that creates OpenTelemetry spans from [Snowpack](https://github.com/HGInsights/snowpack) (Snowflake)
query events.

After installing, setup the handler in your application behaviour before your top-level supervisor starts.

```elixir
OpentelemetrySnowpack.setup(:my_app)
```

See the documentation for `OpentelemetrySnowpack.setup/2` for additional options that may be supplied.

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

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc) and published on
[HexDocs](https://hexdocs.pm). Once published, the docs can be found at
[https://hexdocs.pm/opentelemetry_snowpack](https://hexdocs.pm/opentelemetry_snowpack).
