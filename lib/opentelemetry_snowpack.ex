defmodule OpentelemetrySnowpack do
  @moduledoc """
  OpentelemetrySnowpack uses [telemetry](https://hexdocs.pm/telemetry/) handlers to create `OpenTelemetry` spans.

  Currently it supports Snowpack (Snowflake) query events (start/stop/exception).

  ## Usage

  In your application start:

      def start(_type, _args) do
        OpenTelemetry.register_application_tracer(:my_app)
        OpentelemetrySnowpack.setup()

        children = [
          {Phoenix.PubSub, name: MyApp.PubSub},
          MyAppWeb.Endpoint
        ]

        opts = [strategy: :one_for_one, name: MyStore.Supervisor]
        Supervisor.start_link(children, opts)
      end

  """

  alias OpenTelemetry.Span
  alias OpentelemetrySnowpack.Reason

  require OpenTelemetry.Tracer

  @tracer_id :opentelemetry_snowpack

  @doc """
  Attaches the OpentelemetrySnowpack handler to your Snowpack events. This should be called
  from your application behaviour on startup.

  Example:

      OpentelemetrySnowpack.setup()

  You may also supply the following options in the second argument:

    * `:time_unit` - a time unit used to convert the values of query phase
      timings, defaults to `:microsecond`. See `System.convert_time_unit/3`

    * `:span_prefix` - the first part of the span name, as a `String.t`,
      defaults to the concatenation of the event name with periods, e.g.
      `"snowpack.query.start"`.
  """
  @spec setup(any) :: :ok
  def setup(_opts \\ []) do
    {:ok, otel_snowpack_vsn} = :application.get_key(@tracer_id, :vsn)
    OpenTelemetry.register_tracer(@tracer_id, otel_snowpack_vsn)

    attach_query_start_handler()
    attach_query_stop_handler()
    attach_query_exception_handler()

    :ok
  end

  @doc false
  @spec attach_query_start_handler :: :ok | {:error, :already_exists}
  def attach_query_start_handler do
    :telemetry.attach(
      {__MODULE__, :query_start},
      [:snowpack, :query, :start],
      &__MODULE__.handle_query_start/4,
      %{}
    )
  end

  @doc false
  @spec attach_query_stop_handler :: :ok | {:error, :already_exists}
  def attach_query_stop_handler do
    :telemetry.attach(
      {__MODULE__, :query_stop},
      [:snowpack, :query, :stop],
      &__MODULE__.handle_query_stop/4,
      %{}
    )
  end

  @doc false
  @spec attach_query_exception_handler :: :ok | {:error, :already_exists}
  def attach_query_exception_handler do
    :telemetry.attach(
      {__MODULE__, :query_exception},
      [:snowpack, :query, :exception],
      &__MODULE__.handle_query_exception/4,
      %{}
    )
  end

  @doc false
  @spec handle_query_start(any, any, any, any) :: any
  def handle_query_start(
        _event,
        %{system_time: start_time} = _measurements,
        %{query: query} = meta,
        _config
      ) do
    attributes = [
      # :sql
      "db.type": :snowflake,
      "db.statement": query
    ]

    start_opts = %{start_time: start_time, kind: :client}

    OpentelemetryTelemetry.start_telemetry_span(@tracer_id, "snowpack.query", meta, start_opts)
    |> Span.set_attributes(attributes)
  end

  @doc false
  @spec handle_query_stop(any, any, any, any) :: any
  def handle_query_stop(
        _event,
        %{duration: duration} = _measurements,
        meta,
        _config
      ) do
    # ensure the correct span is current and update
    ctx = OpentelemetryTelemetry.set_current_telemetry_span(@tracer_id, meta)

    if num_rows = Map.get(meta, :num_rows, false) do
      Span.set_attribute(ctx, :"db.num_rows", num_rows)
    end

    attributes = [
      total_time_microseconds: System.convert_time_unit(duration, :native, :microsecond)
    ]

    Span.set_attributes(ctx, attributes)

    if error = Map.get(meta, :error, false) do
      Span.set_status(ctx, OpenTelemetry.status(:error, error_message(error)))
    end

    # end the span
    OpentelemetryTelemetry.end_telemetry_span(@tracer_id, meta)
  end

  @doc false
  @spec handle_query_exception(any, any, any, any) :: any
  def handle_query_exception(
        _event,
        %{duration: duration} = _measurements,
        %{kind: kind, reason: reason, stacktrace: stacktrace} = meta,
        _config
      ) do
    ctx = OpentelemetryTelemetry.set_current_telemetry_span(@tracer_id, meta)

    Span.set_attribute(
      ctx,
      :total_time_microseconds,
      System.convert_time_unit(duration, :native, :microsecond)
    )

    {[reason: reason], attrs} =
      Reason.normalize(reason)
      |> Keyword.split([:reason])

    # try to normalize all errors to Elixir exceptions
    exception = Exception.normalize(kind, reason, stacktrace)

    # record exception and mark the span as errored
    Span.record_exception(ctx, exception, stacktrace, attrs)
    Span.set_status(ctx, OpenTelemetry.status(:error, ""))

    OpentelemetryTelemetry.end_telemetry_span(@tracer_id, meta)
  end

  defp error_message(%{message: message} = _error), do: message
  defp error_message(error) when is_binary(error), do: error
  defp error_message(_error), do: ""
end
