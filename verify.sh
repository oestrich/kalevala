set -e

mix compile --force --warnings-as-errors
mix format --check-formatted
mix test
mix credo
