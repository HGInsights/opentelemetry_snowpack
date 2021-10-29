searchNodes=[{"doc":"OpentelemetrySnowpack uses telemetry handlers to create OpenTelemetry spans. Currently it supports Snowpack (Snowflake) query events (start/stop/exception). Usage In your application start: def start ( _type , _args ) do OpenTelemetry . register_application_tracer ( :my_app ) OpentelemetrySnowpack . setup ( ) children = [ { Phoenix.PubSub , name : MyApp.PubSub } , MyAppWeb.Endpoint ] opts = [ strategy : :one_for_one , name : MyStore.Supervisor ] Supervisor . start_link ( children , opts ) end","ref":"OpentelemetrySnowpack.html","title":"OpentelemetrySnowpack","type":"module"},{"doc":"Attaches the OpentelemetrySnowpack handler to your Snowpack events. This should be called from your application behaviour on startup. Example: OpentelemetrySnowpack . setup ( ) You may also supply the following options in the second argument: :time_unit - a time unit used to convert the values of query phase timings, defaults to :microsecond . See System.convert_time_unit/3 :span_prefix - the first part of the span name, as a String.t , defaults to the concatenation of the event name with periods, e.g. &quot;snowpack.query.start&quot; .","ref":"OpentelemetrySnowpack.html#setup/1","title":"OpentelemetrySnowpack.setup/1","type":"function"},{"doc":"","ref":"OpentelemetrySnowpack.Reason.html","title":"OpentelemetrySnowpack.Reason","type":"module"},{"doc":"","ref":"OpentelemetrySnowpack.Reason.html#normalize/1","title":"OpentelemetrySnowpack.Reason.normalize/1","type":"function"},{"doc":"","ref":"OpentelemetrySnowpack.Reason.html#normalize/2","title":"OpentelemetrySnowpack.Reason.normalize/2","type":"function"},{"doc":"","ref":"changelog.html","title":"CHANGELOG","type":"extras"}]