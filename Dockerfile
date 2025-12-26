# syntax=docker/dockerfile:1

ARG NODE_VERSION=20
FROM node:${NODE_VERSION}-alpine

# ---- Build args ----
ARG FIREBASE_TOOLS_VERSION=latest
ARG JAVA_PACKAGE=openjdk21-jre
ARG PROJECT_ID=demo-project

# Healthcheck configurável
ARG HEALTHCHECK_PORT=4000

# Flags extras para os emuladores
ARG EMULATOR_FLAGS=""

# ---- Runtime env ----
ENV PROJECT_ID="${PROJECT_ID}" \
    EMULATOR_FLAGS="${EMULATOR_FLAGS}" \
    HEALTHCHECK_PORT="${HEALTHCHECK_PORT}"

# Dependências do Firebase Emulator Suite
RUN apk add --no-cache \
    ${JAVA_PACKAGE} \
    curl \
    bash

RUN npm install -g "firebase-tools@${FIREBASE_TOOLS_VERSION}"

WORKDIR /app

COPY .firebaserc firebase.json ./

# Documental — portas padrão (UI + Auth + Firestore + Realtime DB + Pubsub)
EXPOSE 4000 9099 8080 9000 8085

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=3 \
  CMD sh -lc 'curl -fsS "http://localhost:${HEALTHCHECK_PORT}" >/dev/null || exit 1'

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD []