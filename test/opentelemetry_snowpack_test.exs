defmodule OpentelemetrySnowpackTest do
  use ExUnit.Case, async: false

  import OpentelemetrySnowpack.TestHelper

  require OpenTelemetry.Tracer
  require OpenTelemetry.Span
  require Record

  for {name, spec} <- Record.extract_all(from_lib: "opentelemetry/include/otel_span.hrl") do
    Record.defrecord(name, spec)
  end

  for {name, spec} <- Record.extract_all(from_lib: "opentelemetry_api/include/opentelemetry.hrl") do
    Record.defrecord(name, spec)
  end

  setup do
    {:ok, pid} = Snowpack.start_link(key_pair_opts())

    :application.stop(:opentelemetry)
    :application.set_env(:opentelemetry, :tracer, :otel_tracer_default)

    :application.set_env(:opentelemetry, :processors, [
      {:otel_batch_processor, %{scheduled_delay_ms: 1}}
    ])

    :application.start(:opentelemetry)

    :otel_batch_processor.set_exporter(:otel_exporter_pid, self())

    {:ok, [pid: pid]}
  end

  test "captures basic query events", %{pid: pid} do
    OpentelemetrySnowpack.setup()

    Snowpack.query(pid, "SELECT 1")

    assert_receive {:span,
                    span(
                      name: "snowpack.query",
                      attributes: attrs,
                      instrumentation_library:
                        {:instrumentation_library, "opentelemetry_snowpack", _version}
                    )}

    assert [
             "db.error": nil,
             "db.num_rows": 1,
             "db.result": :selected,
             "db.statement": "SELECT 1",
             "db.type": :snowflake,
             total_time_microseconds: _
           ] = List.keysort(attrs, 0)
  end

  test "captures basic query events with errors", %{pid: pid} do
    OpentelemetrySnowpack.setup()

    Snowpack.query(pid, "SELECT * FROM NO_TABLE")

    assert_receive {:span,
                    span(
                      name: "snowpack.query",
                      attributes: attrs,
                      status: {:status, :error, _message} = _status
                    ) = _span},
                   1_000

    assert [
             "db.error": _error,
             "db.num_rows": nil,
             "db.result": nil,
             "db.statement": "SELECT * FROM NO_TABLE",
             "db.type": :snowflake,
             total_time_microseconds: _
           ] = List.keysort(attrs, 0)
  end
end
