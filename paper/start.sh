#!/bin/bash

# Ensure we're in the right place to start
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "${SCRIPTPATH}"

# Update eula.txt with current setting
EULA="${EULA:-false}"
echo "Setting EULA: $EULA"
echo "eula=$EULA" > ./eula.txt

# Add RAM options to Java options if necessary
if [[ -n $PAPERMC_PROJECT_RAM ]]
then
  JAVA_OPTS="-Xms${PAPERMC_PROJECT_RAM} -Xmx${PAPERMC_PROJECT_RAM} $JAVA_OPTS"
fi

# Start server
echo "Starting $PAPERMC_PROJECT_JAR"
exec java -server $JAVA_OPTS -jar "$PAPERMC_PROJECT_JAR" nogui
EXIT_CODE=$?
echo "$PAPERMC_PROJECT_JAR exited with code $EXIT_CODE"
exit $EXIT_CODE