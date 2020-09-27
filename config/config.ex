import Config

config :mojito,
  timeout: 2500,
  pool_opts: [
    size: 1000,
    max_overflow: 1000
    pool: 100
  ]
