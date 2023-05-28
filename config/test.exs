import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :game_of_life, GameOfLifeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "z8YYUfiAv/s2Dxhp7lXwo8kfJve6SyUnRfMcXV2DTEeS/sqqeDKAtbNohJZwU+Es",
  server: false

# In test we don't send emails.
config :game_of_life, GameOfLife.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
