# syntax=docker/dockerfile:1
# escape=\


FROM alpine:latest
ARG PAPERMC_PROJECT=paper
ARG USER=papermc
ARG GROUP=papermc
ARG UID=1001
ARG GID=1001
ARG JRE_PACKAGE=openjdk21-jre

# Environment variables
ENV PAPERMC_PROJECT_VERSION="latest" \
    PAPERMC_PROJECT_BUILD="latest" \
    PAPERMC_PROJECT_CHANNEL="default" \
    PAPERMC_PROJECT_API="https://papermc.io/api/v2/projects" \
    EULA="false" \
    PAPERMC_PROJECT_RAM="" \
    JAVA_OPTS="" \
    PAPERMC_PROJECT=$PAPERMC_PROJECT

# Install dependencies
RUN <<EOL
    apk update
    apk add libstdc++
    apk add ${JRE_PACKAGE}
    apk add bash
    apk add curl
    apk add jq
EOL

# Set USER and GROUP
RUN <<EOL
    addgroup -g ${GID} ${GROUP}
    adduser -u ${UID} -G ${GROUP} -h /opt/papermc -s /bin/sh -D ${USER}
EOL

USER ${UID}
WORKDIR /opt/papermc
COPY --chmod=554 papermc_launcher.sh .
COPY <<EOF ./.papermc_project
#! /usr/bin/env sh
PAPERMC_PROJECT=${PAPERMC_PROJECT}
export PAPERMC_PROJECT
EOF
RUN <<EOL
    mkdir ./papermc_setup &&
    chown ${UID}:${GID} -R ./papermc_setup
EOL
COPY --chmod=554 ${PAPERMC_PROJECT}/* ./papermc_setup/
RUN <<EOL
    mkdir ./${PAPERMC_PROJECT}
    chown ${UID}:${GID} -R ./${PAPERMC_PROJECT}
EOL

# Start script
WORKDIR /opt/papermc
CMD ["bash", "./papermc_launcher.sh"]

# Container setup
EXPOSE 25565/tcp
EXPOSE 25565/udp
VOLUME /opt/papermc/${PAPERMC_PROJECT}