#!/bin/bash

# Ensure we're in the right place to start
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "${SCRIPTPATH}"

: ${PAPERMC_PROJECT_RAM:=1G}

# Add RAM options to Java options if necessary
if [[ -n $JAVA_OPTS ]]
then
  JAVA_OPTS="-Xms${PAPERMC_PROJECT_RAM} -Xmx${PAPERMC_PROJECT_RAM} $JAVA_OPTS"
else
  JAVA_OPTS="-Xms${PAPERMC_PROJECT_RAM} -Xmx${PAPERMC_PROJECT_RAM} -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15"
fi

# Start server
echo "Starting $PAPERMC_PROJECT_JAR"
exec java -server $JAVA_OPTS -jar "$PAPERMC_PROJECT_JAR" nogui
EXIT_CODE=$?
echo "$PAPERMC_PROJECT_JAR exited with code $EXIT_CODE"
exit $EXIT_CODE