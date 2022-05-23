defmodule OpentelemetrySnowpack.MixProject do
  use Mix.Project

  @name "OpentelemetrySnowpack"
  @source_url "https://github.com/HGInsights/opentelemetry_snowpack"

  @version_file Path.join(__DIR__, ".version")
  @external_resource @version_file
  @version (case Regex.run(~r/^([\d\.\w-]+)/, File.read!(@version_file), capture: :all_but_first) do
              [version] -> version
              nil -> "0.0.0"
            end)

  def project do
    [
      app: :opentelemetry_snowpack,
      name: @name,
      description: description(),
      version: @version,
      source_url: @source_url,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      aliases: aliases(),
      bless_suite: bless_suite(),
      deps: deps(),
      dialyzer: dialyzer(),
      docs: docs(),
      package: package(),
      package: package(),
      preferred_cli_env: preferred_cli_env()
    ]
  end

  defp description do
    "Trace Snowpack (Snowflake driver) queries with OpenTelemetry."
  end

  def application do
    []
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG* .version),
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "OpenTelemetry Erlang" => "https://github.com/open-telemetry/opentelemetry-erlang",
        "OpenTelemetry Erlang Contrib" => "https://github.com/open-telemetry/opentelemetry-erlang-contrib",
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
      {:telemetry, "~> 0.4 or ~> 1.0"},
      {:opentelemetry_api, "~> 1.0"},
      {:opentelemetry_telemetry, "~> 1.0"},
      {:opentelemetry, "~> 1.0", only: [:dev, :test]},
      {:opentelemetry_exporter, "~> 1.0", only: [:dev, :test]},
      {:bless, "~> 1.2", only: [:dev, :test]},
      {:excoveralls, "~> 0.14.4", only: [:dev, :test]},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test, :docs], runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:docs], runtime: false},
      {:mix_test_watch, "~> 1.1.0", only: [:test, :dev]}
    ]
  end

  defp preferred_cli_env,
    do: [bless: :test, coveralls: :test, "coveralls.html": :test, credo: :test, docs: :docs, dialyzer: :test, qc: :test]

  defp bless_suite do
    [
      compile: ["--warnings-as-errors", "--force"],
      format: ["--check-formatted"],
      credo: ["--strict"],
      "deps.unlock": ["--check-unused"],
      coveralls: ["--raise", "--exclude", "skip_ci"]
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:ex_unit, :mix],
      ignore_warnings: "dialyzer.ignore-warnings",
      list_unused_filters: true
    ]
  end

  defp aliases do
    [
      qc: ["format", "credo --strict", "test"]
    ]
  end
end
