import Config

config(:logger, :console, format: "$time $metadata[$level] $message\n")

if Mix.env() == :test do
  config(:kantele, :listener, start: false)
  config(:kantele, :telemetry, start: false)
end
