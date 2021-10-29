searchNodes=[{"doc":"OpentelemetrySnowpack uses telemetry handlers to create OpenTelemetry spans. Currently it supports Snowpack (Snowflake) query events (start/stop/exception). Usage In your application start: def start ( _type , _args ) do OpenTelemetry . register_application_tracer ( :my_app ) OpentelemetrySnowpack . setup ( ) children = [ { Phoenix.PubSub , name : MyApp.PubSub } , MyAppWeb.Endpoint ] opts = [ strategy : :one_for_one , name : MyStore.Supervisor ] Supervisor . start_link ( children , opts ) end","ref":"OpentelemetrySnowpack.html","title":"OpentelemetrySnowpack","type":"module"},{"doc":"Attaches the OpentelemetrySnowpack handler to your Snowpack events. This should be called from your application behaviour on startup. Example: OpentelemetrySnowpack . setup ( )","ref":"OpentelemetrySnowpack.html#setup/0","title":"OpentelemetrySnowpack.setup/0","type":"function"},{"doc":"","ref":"OpentelemetrySnowpack.Reason.html","title":"OpentelemetrySnowpack.Reason","type":"module"},{"doc":"","ref":"OpentelemetrySnowpack.Reason.html#normalize/1","title":"OpentelemetrySnowpack.Reason.normalize/1","type":"function"},{"doc":"","ref":"OpentelemetrySnowpack.Reason.html#normalize/2","title":"OpentelemetrySnowpack.Reason.normalize/2","type":"function"},{"doc":"Features first release ( a80b984 )","ref":"changelog.html","title":"0.1.0 (2021-10-29)","type":"extras"}]