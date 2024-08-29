#!/usr/bin/env bash
# Check if OTEL_AGENT_EXTENSION_VERSION and OTEL_BUCKET_NAME environment variables are set
if [ -n "$OTEL_AGENT_EXTENSION_VERSION" ] && [ -n "$OTEL_AGENT_VERSION" ] && [ -n "$OTEL_BUCKET_NAME" ]; then
  if [[ "$OTEL_AGENT_EXTENSION_VERSION" == *SNAPSHOT* ]]; then
    AGENT_EXTENSION_FOLDER="snapshots"
  else
    AGENT_EXTENSION_FOLDER="releases"
  fi
  AGENT_EXTENSION_FILE_NAME=$(aws s3 ls s3://$OTEL_BUCKET_NAME/$AGENT_EXTENSION_FOLDER/ | grep "$OTEL_AGENT_EXTENSION_VERSION" | sed 's/  */ /g' | cut -d ' ' -f4)
  AGENT_FILE_NAME=$(aws s3 ls s3://$OTEL_BUCKET_NAME/ | grep "opentelemetry-javaagent-$OTEL_AGENT_VERSION" | sed 's/  */ /g' | cut -d ' ' -f4)

  # If agent file found, copy it and add as Javaagent
  if [ -n "$AGENT_EXTENSION_FILE_NAME" ] && [ -n "$AGENT_FILE_NAME" ]; then
    AGENT_PATH="/opt/javaagents/$AGENT_FILE_NAME"
    AGENT_EXTENSION_PATH="/opt/javaagents/$AGENT_EXTENSION_FILE_NAME"

    aws s3 cp s3://$OTEL_BUCKET_NAME/$AGENT_EXTENSION_FOLDER/$AGENT_EXTENSION_FILE_NAME $AGENT_EXTENSION_PATH
    aws s3 cp s3://$OTEL_BUCKET_NAME/$AGENT_FILE_NAME $AGENT_PATH
    JAVA_OPTS_APPEND="-javaagent:$AGENT_PATH -Dotel.javaagent.extensions=$AGENT_EXTENSION_PATH $JAVA_OPTS_APPEND"
  else
    echo "Opentelemetry java agent extension $OTEL_AGENT_EXTENSION_VERSION or java agent $OTEL_AGENT_VERSION not found in S3 bucket"
  fi
else
  echo "OTEL_AGENT_EXTENSION_VERSION environment variable is not set"
fi

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

# Stop Kong
kong stop

source /docker-entrypoint.sh "$@"
