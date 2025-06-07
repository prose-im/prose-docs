TITLE: Telemetry
INDEX: 4
UPDATED: 2025-05-31

If you would like to intregrate Prose in your [OpenTelemetry](https://opentelemetry.io/) pipeline, know that the Prose Pod API supports OpenTelemetry out of the box. To enable it, you just need to set 3 environment variables:

```bash
# For gRPC:
OTEL_EXPORTER_OTLP_TRACES_ENDPOINT='http://otel-collector:4317'
OTEL_EXPORTER_OTLP_TRACES_PROTOCOL='grpc'
OTEL_TRACES_SAMPLER='always_on'

# For HTTP:
OTEL_EXPORTER_OTLP_TRACES_ENDPOINT='http://otel-collector:4318/v1/traces'
OTEL_EXPORTER_OTLP_TRACES_PROTOCOL='http/protobuf'
OTEL_TRACES_SAMPLER='always_on'
```

For more information, see [“Configuration based on the environment variables” in davidB/tracing-opentelemetry-instrumentation-sdk/init-tracing-opentelemetry/README.md](https://github.com/davidB/tracing-opentelemetry-instrumentation-sdk/blob/5939f381776146ff92fc6117f7d013a3668fec4e/init-tracing-opentelemetry/README.md#configuration-based-on-the-environment-variables)

You can also have a look at [prose-pod-api/local-run/otel-collector-config.yaml](https://github.com/prose-im/prose-pod-api/blob/4654bda8404a043f4d95a67d3cbd84667cd4f009/local-run/otel-collector-config.yaml)
and [prose-pod-api/local-run/scenarios/default/local-run.env](https://github.com/prose-im/prose-pod-api/blob/4654bda8404a043f4d95a67d3cbd84667cd4f009/local-run/scenarios/default/local-run.env) for an example configuration we use when developing the Prose Pod API. The OpenTelemetry collector is defined in [prose-pod-api/local-run/compose.yaml](https://github.com/prose-im/prose-pod-api/blob/4654bda8404a043f4d95a67d3cbd84667cd4f009/local-run/compose.yaml#L81-L89) and receivers are started using [prose-pod-api/local-run/scripts/otlp](https://github.com/prose-im/prose-pod-api/blob/4654bda8404a043f4d95a67d3cbd84667cd4f009/local-run/scripts/otlp#L272). It’s not production ready but it’s a good base to understand how things relate to one another.

! If you need help setting up telemetry for your self-hosted Prose Pod, feel free to [contact our technical support team](#crisp-chat-open) which will gladly help you set it up.
