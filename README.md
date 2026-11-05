# firebase-emulator-suite

![firebase-emulator-suite logo](assets/logo/logo-symbol-256-transparent.png)

[![Docker Hub](https://img.shields.io/docker/pulls/myfstartup/firebase-emulator-suite)](https://hub.docker.com/r/myfstartup/firebase-emulator-suite) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Docker image for running the **Firebase Local Emulator Suite** in a container, suitable for **local development** and **CI environments**.

This image bundles the Firebase emulators for Authentication, Firestore, Realtime Database, Pub/Sub, Cloud Storage and the Emulator UI, with a predictable and configurable setup.

---

## Features

- Firebase Emulator Suite in a single container
- Supports Auth, Firestore, Realtime Database, Pub/Sub, Storage and Emulator UI
- Emulators are downloaded at build time, so the container starts without network access
- Runs as a non-root user (`node`, uid 1000)
- Configurable Node.js, Alpine, Java and `firebase-tools` versions
- Sensible default ports, aligned with `firebase.json`
- Designed for local development and CI pipelines
- No Firebase login required
- Open source friendly

---

## Included emulators (default)

| Emulator | Port |
| --- | --- |
| Emulator UI | 4000 |
| Authentication | 9099 |
| Firestore | 8080 |
| Realtime Database | 9000 |
| Pub/Sub | 8085 |
| Cloud Storage | 9199 |

These defaults come from the bundled `firebase.json`.

The emulator versions are determined by the `firebase-tools` version: pinning `firebase-tools` pins every emulator at once, and an individual emulator cannot be versioned on its own.

---

## Quick start

```bash
docker run --rm \
  -p 4000:4000 \
  -p 9099:9099 \
  -p 8080:8080 \
  -p 9000:9000 \
  -p 8085:8085 \
  -p 9199:9199 \
  myfstartup/firebase-emulator-suite:latest
```

After startup:

- Emulator UI: <http://localhost:4000>
- Auth Emulator: <http://localhost:9099>
- Firestore Emulator: <http://localhost:8080>
- Realtime DB Emulator: <http://localhost:9000>
- Pub/Sub Emulator: <http://localhost:8085>
- Storage Emulator: <http://localhost:9199>

### Docker Compose

A ready-to-use [docker-compose.yml](docker-compose.yml) is included in this repository, with all ports, a healthcheck and a named volume for emulator data:

```bash
docker compose up -d
```

### Connecting your application

Point the Firebase SDKs and Admin SDKs to the emulators with the standard environment variables:

```bash
export FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
export FIRESTORE_EMULATOR_HOST=localhost:8080
export FIREBASE_DATABASE_EMULATOR_HOST=localhost:9000
export PUBSUB_EMULATOR_HOST=localhost:8085
export FIREBASE_STORAGE_EMULATOR_HOST=localhost:9199
```

Use the default project id `demo-project` (or any id starting with `demo-`), so no real Firebase resources are ever touched.

---

## Image tags

Docker image tags follow the `firebase-tools` version.

For example, when using Firebase CLI version `15.34.2`, the following tags are published:

- `15.34.2` – exact firebase-tools version
- `15.34` – latest patch for this minor version
- `15` – latest patch for this major version
- `latest` – most recent published version

---

## Configuration

### Project ID

The default project id is `demo-project`.

Override it at runtime:

```bash
docker run --rm \
  -e PROJECT_ID=my-project \
  -p 4000:4000 \
  -p 9099:9099 \
  -p 8080:8080 \
  -p 9000:9000 \
  -p 8085:8085 \
  -p 9199:9199 \
  myfstartup/firebase-emulator-suite:latest
```

---

### Limiting emulators

You can restrict which emulators are started using `EMULATOR_FLAGS`:

```bash
docker run --rm \
  -e EMULATOR_FLAGS="--only auth,firestore" \
  -p 4000:4000 \
  -p 9099:9099 \
  -p 8080:8080 \
  myfstartup/firebase-emulator-suite:latest
```

---

### Persisting data

Emulator data can be exported when the container stops and imported again on the next start, using `EMULATOR_FLAGS` and a volume mounted at `/app/data`:

```bash
docker run --rm \
  -e EMULATOR_FLAGS="--import /app/data/export --export-on-exit /app/data/export" \
  -v firebase-emulator-data:/app/data \
  -p 4000:4000 \
  -p 9099:9099 \
  -p 8080:8080 \
  -p 9000:9000 \
  -p 8085:8085 \
  -p 9199:9199 \
  myfstartup/firebase-emulator-suite:latest
```

Things to keep in mind:

- The export target must be a **subdirectory** of the mounted volume (such as `/app/data/export`). Exporting directly to `/app/data` fails with `EBUSY` because the mount point cannot be recreated.
- The export runs when the container receives `SIGTERM`, so stop it with `docker stop` or `docker compose stop`. Killing the container skips the export.
- The container runs as uid 1000, so a bind-mounted host directory must be writable by that user. Named volumes inherit the correct ownership automatically.

---

## Healthcheck

The container healthcheck probes the Emulator UI by default:

```bash
http://127.0.0.1:4000
```

This port can be changed if needed:

```bash
docker run --rm \
  -e HEALTHCHECK_PORT=9099 \
  myfstartup/firebase-emulator-suite:latest
```

The default probe depends on the Emulator UI. If you disable it (for example with `--only`), point `HEALTHCHECK_PORT` to another emulator.

---

## Custom firebase.json and .firebaserc

You can provide your own configuration files via volume mounts:

```bash
docker run --rm \
  -v "$PWD/firebase.json:/app/firebase.json:ro" \
  -v "$PWD/.firebaserc:/app/.firebaserc:ro" \
  -p 4000:4000 \
  -p 9099:9099 \
  -p 8080:8080 \
  -p 9000:9000 \
  -p 8085:8085 \
  -p 9199:9199 \
  myfstartup/firebase-emulator-suite:latest
```

This allows full customization without rebuilding the image.

---

## Build customization

The image supports the following build arguments:

| ARG | Default | Description |
| --- | --- | --- |
| NODE_VERSION | 20 | Node.js major version |
| ALPINE_VERSION | 3.22 | Alpine Linux version of the base image |
| JAVA_PACKAGE | openjdk21-jre | Java runtime used by emulators |
| FIREBASE_TOOLS_VERSION | 15.34.2 | Version of firebase-tools (also pins every emulator) |
| PROJECT_ID | demo-project | Default Firebase project id |
| HEALTHCHECK_PORT | 4000 | Port used by Docker healthcheck |

Example:

```bash
docker build \
  --build-arg FIREBASE_TOOLS_VERSION=15.34.2 \
  -t myfstartup/firebase-emulator-suite:15.34.2 .
```

Only the default combination (Node 20, Java 21, Alpine 3.22, firebase-tools 15.34.2) is tested. Other combinations may work, but check the `engines` field of the chosen `firebase-tools` version and the Java version it requires.

---

## EXPOSE and ports

The `EXPOSE` directive is used only as documentation and reflects the default emulator ports.

Actual port bindings are defined at runtime using `-p` or `docker-compose`.

---

## CI usage

This image is suitable for CI pipelines (GitHub Actions, GitLab CI, etc.) where Firebase emulators are required for integration or end-to-end tests.

Typical usage:

- Start container
- Wait until the healthcheck reports `healthy`
- Run tests against emulator endpoints
- Stop container

Example for GitLab CI, using the image as a service:

```yaml
integration-tests:
  image: node:20
  services:
    - name: myfstartup/firebase-emulator-suite:15.34.2
      alias: firebase
  variables:
    FIRESTORE_EMULATOR_HOST: firebase:8080
    FIREBASE_AUTH_EMULATOR_HOST: firebase:9099
  script:
    - npm ci
    - npm test
```

GitLab waits for the service ports to be reachable before starting the job.

---

## Security

The emulators listen on `0.0.0.0` inside the container and the default security rules are open. This image is intended for local development and CI only, so do not expose its ports on a public network.

---

## Troubleshooting

- **`Export failed: EBUSY`**: the export target is the mount point itself. Use a subdirectory, such as `/app/data/export`.
- **Permission denied writing to a mounted directory**: the container runs as uid 1000. Make the host directory writable by that user, or use a named volume.
- **Port already in use**: change the host side of the mapping (for example `-p 18080:8080`), keeping the container port unchanged.
- **Container reported `unhealthy`**: the default healthcheck probes the Emulator UI. Check `HEALTHCHECK_PORT` if you disabled it.

---

## Links

- Docker Hub: <https://hub.docker.com/r/myfstartup/firebase-emulator-suite>
- Source code and issues: <https://github.com/my-f-startup/firebase-emulator-suite>
- Firebase Emulator Suite documentation: <https://firebase.google.com/docs/emulator-suite>

---

## License

Released under the [MIT License](LICENSE).

---

## Disclaimer

> This project is not officially affiliated with Firebase or Google. Firebase is a trademark of Google LLC.
