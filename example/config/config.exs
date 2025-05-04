import Config

config(:logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:pid, :request_id]
)

config(:kantele, :accounts_path, "data/accounts")

if Mix.env() == :test do
  config(:kantele, :accounts_path, "test/data/accounts")

  config(:kantele, :listener, start: false)
  config(:kantele, :world, kickoff: false)

  config(:logger, level: :warn)

  config(:bcrypt_elixir, log_rounds: 2)
end
