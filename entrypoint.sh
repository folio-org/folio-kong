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

# Override CORS origins from environment variable (KONG-48)
# This runs after deck sync but while the temporary Kong (for deck) is still running.
# When CORS_ORIGINS is unset/empty, the deck-synced origins: ['*'] from cors.yaml remains in effect.
if [ -n "${CORS_ORIGINS:-}" ]; then
  echo "CORS_ORIGINS is set — overriding origins via Kong Admin API..."

  # Build JSON array from space-separated list (URLs or PCRE regexes).
  # Done this way to spare operators from JSON escaping in the env var.
  # Normalize internal whitespace so multiple spaces don't create empty entries.
  # We must double backslashes (for regexes like .*\.example.com) so the resulting
  # string is valid JSON and Kong receives a correct PCRE pattern.
  origins_json="["
  first=true
  for origin in ${CORS_ORIGINS}; do
    if [ "$first" = true ]; then
      first=false
    else
      origins_json="${origins_json},"
    fi
    # Escape backslashes and double quotes for safe embedding in JSON string
    escaped=$(printf '%s' "$origin" | sed 's/\\/\\\\/g; s/"/\\"/g')
    origins_json="${origins_json}\"${escaped}\""
  done
  origins_json="${origins_json}]"

  # Find the actual plugin ID of the cors plugin instance created by deck
  # (we cannot PATCH /plugins/cors by name reliably; we need the UUID).
  plugin_id=$(curl -s http://localhost:8001/plugins \
    | grep -o '"id":"[^"]*","name":"cors"' | head -1 | cut -d'"' -f4)

  if [ -n "$plugin_id" ]; then
    echo "Patching /plugins/${plugin_id} with origins: ${origins_json}"
    curl -s -X PATCH "http://localhost:8001/plugins/${plugin_id}" \
      -H "Content-Type: application/json" \
      -d "{\"config\": {\"origins\": ${origins_json}}}"
    echo "CORS origins override complete."
  else
    echo "WARNING: Could not locate the cors plugin ID after deck sync. CORS_ORIGINS override skipped."
  fi
fi

# Stop Kong
kong stop

source /docker-entrypoint.sh "$@"
