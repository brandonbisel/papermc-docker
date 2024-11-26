#!/usr/bin/env sh

# Ensure we're in the right place to start
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
cd "${SCRIPTPATH}"

# Load internal variables
. ./.papermc_project
. ./papermc_internal_vars.sh

# Initialize / clean up environment variables
: ${PAPERMC_PROJECT_VERSION:='latest'}
: ${PAPERMC_PROJECT_BUILD:='latest'}
: ${PAPERMC_PROJECT_API:="https://papermc.io/api/v2/projects"}
: ${PAPERMC_PROJECT_CHANNEL:='default'}

PAPERMC_PROJECT_BUILD="${PAPERMC_PROJECT_BUILD,,}"

echo "Starting ${PAPERMC_PROJECT}"

echo "PAPERMC_PROJECT_API: ${PAPERMC_PROJECT_API}"
echo "PROJECT: ${PAPERMC_PROJECT}"
echo "PAPERMC_PROJECT_VERSION: ${PAPERMC_PROJECT_VERSION}"
echo "PAPERMC_PROJECT_BUILD: ${PAPERMC_PROJECT_BUILD}"


# Get version information
if [[ "$PAPERMC_PROJECT_VERSION" == "latest" ]]
then
  # Get the latest Minecraft version
  PAPERMC_PROJECT_VERSION=$(curl -s "${PAPERMC_PROJECT_API}/${PAPERMC_PROJECT}" | jq -r '.versions[-1]')
  echo "Latest ${PAPERMC_PROJECT} version: ${PAPERMC_PROJECT_VERSION}"
fi

if [[ "$PAPERMC_PROJECT_BUILD" == "latest" ]]
then
  # Get the latest build
  PAPERMC_PROJECT_BUILD=$(curl -s "${PAPERMC_PROJECT_API}/${PAPERMC_PROJECT}/versions/${PAPERMC_PROJECT_VERSION}/builds" | jq -r ".builds | map(select(.channel == \"${PAPERMC_PROJECT_CHANNEL}\") | .build) | .[-1]")

    if [ "$PAPERMC_PROJECT_BUILD" == "null" ]
    then
        echo "No ${PAPERMC_PROJECT_CHANNEL} build for version ${PAPERMC_PROJECT_VERSION} found :("

        if [ "$PAPERMC_PROJECT_CHANNEL" == "experimental" ]
        then
            PAPERMC_PROJECT_CHANNEL="default"
            PAPERMC_PROJECT_BUILD=$(curl -s "${PAPERMC_PROJECT_API}/${PAPERMC_PROJECT}/versions/${PAPERMC_PROJECT_VERSION}/builds" | jq -r ".builds | map(select(.channel == \"${PAPERMC_PROJECT_CHANNEL}\") | .build) | .[-1]")
        else
            PAPERMC_PROJECT_VERSION=$(curl -s "${PAPERMC_PROJECT_API}/${PAPERMC_PROJECT}" | jq -r '.versions[-2]')
            PAPERMC_PROJECT_BUILD=$(curl -s "${PAPERMC_PROJECT_API}/${PAPERMC_PROJECT}/versions/${PAPERMC_PROJECT_VERSION}/builds" | jq -r ".builds | map(select(.channel == \"${PAPERMC_PROJECT_CHANNEL}\") | .build) | .[-1]")
        fi
        echo "Using latest ${PAPERMC_PROJECT_CHANNEL} build: ${PAPERMC_PROJECT_VERSION}:${PAPERMC_PROJECT_BUILD}"
    fi

  echo "Latest ${PAPERMC_PROJECT_CHANNEL} ${PAPERMC_PROJECT} build: ${PAPERMC_PROJECT_BUILD}"
fi
PAPERMC_PROJECT_JAR="${PAPERMC_PROJECT}-${PAPERMC_PROJECT_VERSION}-${PAPERMC_PROJECT_BUILD}.jar"
PAPER_DOWNLOAD="${PAPERMC_PROJECT_API}/${PAPERMC_PROJECT}/versions/${PAPERMC_PROJECT_VERSION}/builds/${PAPERMC_PROJECT_BUILD}/downloads/${PAPERMC_PROJECT_JAR}"

# Update if necessary
if [[ ! -e $PAPERMC_PROJECT_JAR ]]
then
  echo "Removing old versions"
  # Remove old server jar(s)
  rm -f *.jar
  echo "Downloading $PAPERMC_PROJECT_JAR"
  # Download new server jar
  curl -o "./${PAPERMC_PROJECT}/$PAPERMC_PROJECT_JAR" "$PAPER_DOWNLOAD"
fi

# Start the server
export PAPERMC_PROJECT_JAR
cp -nR ./papermc_setup/* "${PAPERMC_PROJECT}/"
cd "/opt/papermc/${PAPERMC_PROJECT}"
exec ./start.sh