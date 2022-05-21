defmodule OpentelemetrySnowpackTest do
  use ExUnit.Case, async: true

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
    :application.stop(:opentelemetry)
    :application.set_env(:opentelemetry, :tracer, :otel_tracer_default)

    :application.set_env(:opentelemetry, :processors, [
      {:otel_batch_processor, %{scheduled_delay_ms: 1}}
    ])

    :application.start(:opentelemetry)

    :otel_batch_processor.set_exporter(:otel_exporter_pid, self())

    :ok
  end

  test "captures basic query events" do
    OpentelemetrySnowpack.setup()

    :telemetry.execute(
      [:snowpack, :query, :start],
      %{system_time: System.system_time()},
      %{query: "SELECT 1"}
    )

    :telemetry.execute(
      [:snowpack, :query, :stop],
      %{duration: 101},
      %{result: :selected, num_rows: 1}
    )

    assert_receive {:span,
                    span(
                      name: "snowpack.query",
                      attributes: attrs
                    )}

    assert {:attributes, _, :infinity, _,
            %{
              "db.error": nil,
              "db.num_rows": 1,
              "db.result": :selected,
              "db.statement": "SELECT 1",
              "db.type": :snowflake,
              total_time_microseconds: _
            }} = attrs

    OpentelemetrySnowpack.teardown()
  end

  test "captures query params if options configured" do
    OpentelemetrySnowpack.setup(trace_query_params: true)

    :telemetry.execute(
      [:snowpack, :query, :start],
      %{system_time: System.system_time()},
      %{query: "SELECT ? * ?", params: [sql_integer: [2], sql_integer: [3]]}
    )

    :telemetry.execute(
      [:snowpack, :query, :stop],
      %{duration: 101},
      %{result: :selected, num_rows: 1}
    )

    assert_receive {:span,
                    span(
                      name: "snowpack.query",
                      attributes: attrs
                    )}

    assert {:attributes, _, :infinity, _,
            %{
              "db.error": nil,
              "db.num_rows": 1,
              "db.params": "[sql_integer: [2], sql_integer: [3]]",
              "db.result": :selected,
              "db.statement": "SELECT ? * ?",
              "db.type": :snowflake,
              total_time_microseconds: _
            }} = attrs

    OpentelemetrySnowpack.teardown()
  end

  test "captures basic query events with errors" do
    OpentelemetrySnowpack.setup()

    :telemetry.execute(
      [:snowpack, :query, :start],
      %{system_time: System.system_time()},
      %{query: "SELECT * FROM NO_TABLE"}
    )

    :telemetry.execute(
      [:snowpack, :query, :stop],
      %{duration: 101},
      %{error: RuntimeError.exception("Failed!")}
    )

    assert_receive {:span,
                    span(
                      name: "snowpack.query",
                      attributes: attrs,
                      status: {:status, :error, message} = _status
                    ) = _span},
                   1_000

    assert message == "Failed!"

    assert {:attributes, _, :infinity, _,
            %{
              "db.error": ~s<{"__exception__":true,"message":"Failed!"}>,
              "db.num_rows": nil,
              "db.result": nil,
              "db.statement": "SELECT * FROM NO_TABLE",
              "db.type": :snowflake,
              total_time_microseconds: _
            }} = attrs

    OpentelemetrySnowpack.teardown()
  end

  test "ignores query errors if options configured" do
    OpentelemetrySnowpack.setup(trace_query_error: false)

    :telemetry.execute(
      [:snowpack, :query, :start],
      %{system_time: System.system_time()},
      %{query: "SELECT * FROM NO_TABLE"}
    )

    :telemetry.execute(
      [:snowpack, :query, :stop],
      %{duration: 101},
      %{error: RuntimeError.exception("Failed!")}
    )

    assert_receive {:span,
                    span(
                      name: "snowpack.query",
                      attributes: attrs,
                      status: {:status, :error, _error} = _status
                    ) = _span},
                   1_000

    assert {:attributes, _, :infinity, _,
            %{
              "db.num_rows": nil,
              "db.result": nil,
              "db.statement": "SELECT * FROM NO_TABLE",
              "db.type": :snowflake,
              total_time_microseconds: _
            }} = attrs

    OpentelemetrySnowpack.teardown()
  end

  test "reports query exceptions" do
    OpentelemetrySnowpack.setup()

    :telemetry.execute(
      [:snowpack, :query, :start],
      %{system_time: System.system_time()},
      %{query: "SELECT 1"}
    )

    :telemetry.execute(
      [:snowpack, :query, :exception],
      %{duration: 123},
      %{kind: :error, error: RuntimeError.exception("Failed!"), stacktrace: []}
    )

    assert_receive {:span,
                    span(
                      name: "snowpack.query",
                      attributes: attrs,
                      events: events,
                      status: status
                    )}

    assert {:attributes, _, :infinity, _,
            %{
              "db.statement": "SELECT 1",
              "db.type": :snowflake,
              total_time_microseconds: _
            }} = attrs

    assert {:events, _, _, :infinity, _,
            [
              {:event, _, "exception",
               {:attributes, _, :infinity, _,
                %{
                  "exception.message" => "Failed!",
                  "exception.stacktrace" => _stacktrace,
                  "exception.type" => "Elixir.RuntimeError"
                }}}
            ]} = events

    assert {:status, :error, "Failed!"} = status

    OpentelemetrySnowpack.teardown()
  end
end
