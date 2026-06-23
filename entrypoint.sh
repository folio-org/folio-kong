#!/usr/bin/env bash

config_path="/opt/kong/config"
export KONG_PLUGINS="$KONG_PLUGINS,auth-headers-manager"

# Bootstrap Kong
kong migrations bootstrap
kong migrations up
kong migrations finish

# Start Kong
kong start

# Wait for Kong to start up
until curl -s http://localhost:8001 >/dev/null 2>&1; do
  echo "Waiting for Kong to start..."
  sleep 1
done

echo "Kong initialization..."

# Convert CORS_ORIGINS (space-separated URLs/PCREs) to a YAML block sequence and export it
# as DECK_CORS_ORIGINS for deck template substitution in cors.yaml.
# Single-quoted YAML strings treat backslashes literally, so PCRE patterns pass through unchanged.
echo "CORS setup: CORS_ORIGINS='${CORS_ORIGINS:-}'"
if [ -n "${CORS_ORIGINS:-}" ]; then
  echo "CORS setup: CORS_ORIGINS is set — building DECK_CORS_ORIGINS from provided values..."
  deck_cors_origins=""
  for origin in ${CORS_ORIGINS}; do
    deck_cors_origins="${deck_cors_origins}
      - '${origin}'"
    echo "CORS setup: added origin '${origin}'"
  done
else
  echo "CORS setup: CORS_ORIGINS is unset — using default wildcard origin"
  deck_cors_origins="
      - '*'"
fi
export DECK_CORS_ORIGINS="${deck_cors_origins}"
echo "CORS setup: DECK_CORS_ORIGINS=${DECK_CORS_ORIGINS}"

# Get the names of all files in the config directory
config_files=$(ls $config_path)

# Create the deck command with each file as a separate -s option
deck_cmd="deck sync --select-tag=automation"
for file in $config_files; do
  deck_cmd="$deck_cmd -s $config_path/$file"
done

# Run the deck command
echo "$deck_cmd"
$deck_cmd

echo "Kong initialization finished successfully!"

# Stop Kong
kong stop

source /docker-entrypoint.sh "$@"
