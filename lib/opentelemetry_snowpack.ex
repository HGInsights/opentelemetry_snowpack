defmodule OpentelemetrySnowpack do
  @external_resource "README.md"

  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias OpenTelemetry.Span

  require OpenTelemetry.Tracer

  @tracer_id :opentelemetry_snowpack

  @default_config [
    span_name: "snowpack.query",
    trace_query_statement: true,
    trace_query_params: false,
    trace_query_error: true
  ]

  @doc """
  Attaches the OpentelemetrySnowpack handler to your Snowpack events. This should be called
  from your application behaviour on startup.

  Example:

      OpentelemetrySnowpack.setup()

  """
  @spec setup(keyword) :: :ok
  def setup(opts \\ []) do
    config =
      @default_config
      |> Keyword.merge(Application.get_env(@tracer_id, :trace_options, []))
      |> Keyword.merge(opts)
      |> Enum.into(%{})

    attach_query_start_handler(config)
    attach_query_stop_handler(config)
    attach_query_exception_handler(config)

    :ok
  end

  @doc false
  @spec attach_query_start_handler(map) :: :ok | {:error, :already_exists}
  def attach_query_start_handler(config) do
    :telemetry.attach(
      {__MODULE__, :query_start},
      [:snowpack, :query, :start],
      &__MODULE__.handle_query_start/4,
      config
    )
  end

  @doc false
  @spec attach_query_stop_handler(map) :: :ok | {:error, :already_exists}
  def attach_query_stop_handler(config) do
    :telemetry.attach(
      {__MODULE__, :query_stop},
      [:snowpack, :query, :stop],
      &__MODULE__.handle_query_stop/4,
      config
    )
  end

  @doc false
  @spec attach_query_exception_handler(map) :: :ok | {:error, :already_exists}
  def attach_query_exception_handler(config) do
    :telemetry.attach(
      {__MODULE__, :query_exception},
      [:snowpack, :query, :exception],
      &__MODULE__.handle_query_exception/4,
      config
    )
  end

  @doc false
  @spec teardown :: :ok | {:error, :not_found}
  def teardown do
    :telemetry.detach({__MODULE__, :query_start})
    :telemetry.detach({__MODULE__, :query_stop})
    :telemetry.detach({__MODULE__, :query_exception})
  end

  @doc false
  @spec handle_query_start(any, any, any, any) :: any
  def handle_query_start(_event, _measurements, metadata, config) do
    attributes =
      ["db.type": :snowflake]
      |> put_if(
        config.trace_query_statement,
        {:"db.statement", metadata[:query]}
      )
      |> put_if(config.trace_query_params, {:"db.params", inspect(metadata[:params])})

    start_opts = %{kind: :client}

    @tracer_id
    |> OpentelemetryTelemetry.start_telemetry_span(config.span_name, metadata, start_opts)
    |> Span.set_attributes(attributes)
  end

  @doc false
  @spec handle_query_stop(any, any, any, any) :: any
  def handle_query_stop(
        _event,
        %{duration: duration} = _measurements,
        metadata,
        config
      ) do
    # ensure the correct span is current and update
    ctx = OpentelemetryTelemetry.set_current_telemetry_span(@tracer_id, metadata)

    error = metadata[:error]

    attributes =
      put_if(
        [
          "db.num_rows": metadata[:num_rows],
          "db.result": metadata[:result],
          total_time_microseconds: System.convert_time_unit(duration, :native, :microsecond)
        ],
        config.trace_query_error,
        {:"db.error", encode_error(error)}
      )

    set_status(ctx, error)
    Span.set_attributes(ctx, attributes)

    OpentelemetryTelemetry.end_telemetry_span(@tracer_id, metadata)
  end

  @doc false
  @spec handle_query_exception(any, any, any, any) :: any
  def handle_query_exception(
        _event,
        %{duration: duration} = _measurements,
        %{error: error, stacktrace: stacktrace} = metadata,
        _config
      ) do
    # ensure the correct span is current and update
    ctx = OpentelemetryTelemetry.set_current_telemetry_span(@tracer_id, metadata)

    attributes = [
      total_time_microseconds: System.convert_time_unit(duration, :native, :microsecond)
    ]

    # record exception and mark the span as errored
    Span.record_exception(ctx, error, stacktrace)

    set_status(ctx, error)
    Span.set_attributes(ctx, attributes)

    OpentelemetryTelemetry.end_telemetry_span(@tracer_id, metadata)
  end

  # Surprisingly, there doesn't seem to be anything in the stdlib to conditionally
  # put stuff in a list / keyword list.
  # This snippet is approved by José himself:
  # https://elixirforum.com/t/creating-list-adding-elements-on-specific-conditions/6295/4?u=learts
  defp put_if(list, false, _), do: list
  defp put_if(list, true, value), do: [value | list]

  defp set_status(_ctx, nil), do: :ok
  # coveralls-ignore-start
  defp set_status(_ctx, []), do: :ok
  # coveralls-ignore-stop

  defp set_status(ctx, error),
    do: Span.set_status(ctx, OpenTelemetry.status(:error, error_message(error)))

  defp error_message(%{message: message} = _error), do: message
  # coveralls-ignore-start
  defp error_message(error) when is_exception(error), do: Exception.message(error)
  defp error_message(error) when is_binary(error), do: error
  defp error_message(_error), do: ""
  # coveralls-ignore-stop

  defp encode_error(error) when is_struct(error), do: error |> Map.from_struct() |> encode_error()
  defp encode_error(error) when is_map(error), do: Jason.encode!(error)
  defp encode_error(nil), do: nil
end
