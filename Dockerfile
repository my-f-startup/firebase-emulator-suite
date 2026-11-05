# syntax=docker/dockerfile:1

ARG NODE_VERSION=20
ARG ALPINE_VERSION=3.22
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION}

# ---- Build args ----
ARG FIREBASE_TOOLS_VERSION=15.34.2
ARG JAVA_PACKAGE=openjdk21-jre
ARG PROJECT_ID=demo-project

# Configurable healthcheck
ARG HEALTHCHECK_PORT=4000

# Extra flags for the emulators
ARG EMULATOR_FLAGS=""

# ---- Runtime env ----
# FIREBASE_EMULATORS_PATH: emulator cache directory, outside HOME and owned by the non-root user
ENV PROJECT_ID="${PROJECT_ID}" \
    EMULATOR_FLAGS="${EMULATOR_FLAGS}" \
    HEALTHCHECK_PORT="${HEALTHCHECK_PORT}" \
    FIREBASE_EMULATORS_PATH=/opt/firebase-emulators

# Firebase Emulator Suite dependencies, CLI install and directories owned by the non-root user
# (/app/data is the mount point for exported emulator data)
RUN apk add --no-cache \
        ${JAVA_PACKAGE} \
        curl \
        bash \
    && npm install -g "firebase-tools@${FIREBASE_TOOLS_VERSION}" \
    && npm cache clean --force \
    && mkdir -p "${FIREBASE_EMULATORS_PATH}" /app/data \
    && chown -R node:node "${FIREBASE_EMULATORS_PATH}" /app

USER node

# The CLI writes firebase-debug.log to the current directory, so it must be writable by the non-root user
WORKDIR /app

# Download ALL emulators that ship a binary at build time, so container startup does not depend on the network
# (auth, functions, hosting, etc. are bundled with firebase-tools)
RUN firebase setup:emulators:firestore \
    && firebase setup:emulators:database \
    && firebase setup:emulators:pubsub \
    && firebase setup:emulators:storage \
    && firebase setup:emulators:ui \
    && rm -f firebase-debug.log

COPY --chown=node:node .firebaserc firebase.json ./
COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Documentation only — default ports (UI + Auth + Firestore + Realtime DB + Pubsub + Storage)
EXPOSE 4000 9099 8080 9000 8085 9199

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
    CMD sh -c 'curl -fsS "http://127.0.0.1:${HEALTHCHECK_PORT}" >/dev/null || exit 1'

ENTRYPOINT ["docker-entrypoint.sh"]

# OCI image metadata
LABEL org.opencontainers.image.title="firebase-emulator-suite" \
    org.opencontainers.image.description="Firebase Emulator Suite with emulators pre-downloaded at build time" \
    org.opencontainers.image.version="${FIREBASE_TOOLS_VERSION}"
