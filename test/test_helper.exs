Code.put_compiler_option(:warnings_as_errors, true)
Vapor.load!([%Vapor.Provider.Dotenv{}])

ExUnit.start(exclude: [skip: true])

defmodule OpentelemetrySnowpack.TestHelper do
  @spec odbc_ini_opts :: keyword()
  def odbc_ini_opts do
    [
      connection: [
        dsn: System.get_env("SNOWPACK_DSN_NAME", "snowpack")
      ],
      pool_size: 1
    ]
  end

  @spec key_pair_opts :: keyword()
  def key_pair_opts do
    [
      connection: [
        driver: System.fetch_env!("SNOWPACK_DRIVER"),
        server: System.fetch_env!("SNOWPACK_SERVER"),
        role: System.fetch_env!("SNOWPACK_KEYPAIR_ROLE"),
        warehouse: System.fetch_env!("SNOWPACK_KEYPAIR_WAREHOUSE"),
        database: System.fetch_env!("SNOWPACK_KEYPAIR_DATABASE"),
        schema: System.fetch_env!("SNOWPACK_KEYPAIR_SCHEMA"),
        uid: System.fetch_env!("SNOWPACK_KEYPAIR_UID"),
        authenticator: System.fetch_env!("SNOWPACK_KEYPAIR_AUTHENTICATOR"),
        priv_key_file: System.fetch_env!("SNOWPACK_PRIV_KEY_FILE")
      ],
      pool_size: 1
    ]
  end
end
