import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :restaurant_access, RestaurantAccess.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "restaurant_access_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# In test we don't send emails
# config :restaurant_access, RestaurantAccess.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
# config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
# config :phoenix, :plug_init_mode, :runtime

# Sort query params output of verified routes for robust url comparisons
# config :phoenix,
#   sort_verified_routes_query_params: true
