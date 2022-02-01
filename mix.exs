defmodule OpentelemetrySnowpack.MixProject do
  use Mix.Project

  @name "OpentelemetrySnowpack"
  @version "0.3.0"
  @source_url "https://github.com/HGInsights/opentelemetry_snowpack"

  def project do
    [
      app: :opentelemetry_snowpack,
      name: @name,
      description: description(),
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      source_url: @source_url,
      package: package(),
      docs: docs(),
      preferred_cli_env: preferred_cli_env(),
      dialyzer: dialyzer()
    ]
  end

  defp description do
    "Trace Snowpack (Snowflake) queries with OpenTelemetry."
  end

  def application do
    []
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["Apache-2"],
      links: %{
        "GitHub" => @source_url,
        "OpenTelemetry Erlang" => "https://github.com/open-telemetry/opentelemetry-erlang",
        "OpenTelemetry Erlang Contrib" =>
          "https://github.com/open-telemetry/opentelemetry-erlang-contrib",
        "OpenTelemetry.io" => "https://opentelemetry.io"
      }
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      source_url: @source_url,
      main: @name,
      extras: ["CHANGELOG.md"],
      groups_for_extras: [
        CHANGELOG: "CHANGELOG.md"
      ]
    ]
  end

  defp deps do
    [
      {:telemetry, "~> 1.0.0", override: true},
      {:opentelemetry_api, "~> 1.0"},
      {:opentelemetry_telemetry, "~> 1.0.0-beta.7"},
      {:opentelemetry, "~> 1.0", only: [:dev, :test]},
      {:opentelemetry_exporter, "~> 1.0", only: [:dev, :test]},
      {:snowpack, github: "HGInsights/snowpack", tag: "v0.5.7", only: [:dev, :test]},
      {:vapor, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.28", only: [:dev], runtime: false}
    ]
  end

  defp preferred_cli_env, do: [qc: :test, credo: :test, dialyzer: :test]

  defp dialyzer do
    [
      plt_add_apps: [:ex_unit, :mix],
      ignore_warnings: "dialyzer.ignore-warnings"
    ]
  end

  defp aliases do
    [
      qc: ["format", "credo --strict", "test"]
    ]
  end
end
