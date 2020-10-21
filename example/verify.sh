set -ex

mix compile --force --warnings-as-errors
mix format --check-formatted
mix test
mix credo

cd assets
yarn lint-ci
yarn jest
