<p align="center">
  <img src="assets/logo/logo-symbol-256.png" width="96" />
</p>

# firebase-emulator-suite

Docker image for running the **Firebase Local Emulator Suite** in a container, suitable for **local development** and **CI environments**.

This image bundles the Firebase emulators for Authentication, Firestore, Realtime Database, Pub/Sub and the Emulator UI, with a predictable and configurable setup.

---

## Features

- Firebase Emulator Suite in a single container
- Supports Auth, Firestore, Realtime Database, Pub/Sub and Emulator UI
- Configurable Node.js, Java and `firebase-tools` versions
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

These defaults come from the bundled `firebase.json`.

---

## Quick start

```bash
docker run --rm   -p 4000:4000   -p 9099:9099   -p 8080:8080   -p 9000:9000   -p 8085:8085   myfstartup/firebase-emulator-suite:latest
```

After startup:

- Emulator UI: <http://localhost:4000>
- Auth Emulator: <http://localhost:9099>
- Firestore Emulator: <http://localhost:8080>
- Realtime DB Emulator: <http://localhost:9000>
- Pub/Sub Emulator: <http://localhost:8085>

---

## Image tags

Docker image tags follow the `firebase-tools` version.

For example, when using Firebase CLI version `13.15.4`, the following tags are published:

- `13.15.4` – exact firebase-tools version
- `13.15` – latest patch for this minor version
- `13` – latest patch for this major version
- `latest` – most recent published version

---

## Configuration

### Project ID

The default project id is `demo-project`.

Override it at runtime:

```bash
docker run --rm   -e PROJECT_ID=my-project   -p 4000:4000   -p 9099:9099   -p 8080:8080   -p 9000:9000   -p 8085:8085  myfstartup/firebase-emulator-suite:latest
```

---

### Limiting emulators

You can restrict which emulators are started using `EMULATOR_FLAGS`:

```bash
docker run --rm   -e EMULATOR_FLAGS="--only auth,firestore"   -p 4000:4000   -p 9099:9099   -p 8080:8080   myfstartup/firebase-emulator-suite:latest
```

---

## Healthcheck

The container healthcheck probes the Emulator UI by default:

```bash
http://localhost:4000
```

This port can be changed if needed:

```bash
docker run --rm   -e HEALTHCHECK_PORT=9099   myfstartup/firebase-emulator-suite:latest
```

---

## Custom firebase.json and .firebaserc

You can provide your own configuration files via volume mounts:

```bash
docker run --rm   -v "$PWD/firebase.json:/app/firebase.json:ro"   -v "$PWD/.firebaserc:/app/.firebaserc:ro"   -p 4000:4000   -p 9099:9099   -p 8080:8080   -p 9000:9000   -p 8085:8085   myfstartup/firebase-emulator-suite:latest
```

This allows full customization without rebuilding the image.

---

## Build customization

The image supports the following build arguments:

| ARG | Default | Description |
| --- | --- | --- |
| NODE_VERSION | 20 | Node.js major version |
| JAVA_PACKAGE | openjdk21-jre | Java runtime used by emulators |
| FIREBASE_TOOLS_VERSION | latest | Version of firebase-tools |
| PROJECT_ID | demo-project | Default Firebase project id |
| HEALTHCHECK_PORT | 4000 | Port used by Docker healthcheck |

Example:

```bash
docker build   --build-arg NODE_VERSION=22   --build-arg JAVA_PACKAGE=openjdk17-jre   --build-arg FIREBASE_TOOLS_VERSION=13.15.4   -t myfstartup/firebase-emulator-suite:node22-java17 .
```

---

## EXPOSE and ports

The `EXPOSE` directive is used only as documentation and reflects the default emulator ports.

Actual port bindings are defined at runtime using `-p` or `docker-compose`.

---

## CI usage

This image is suitable for CI pipelines (GitHub Actions, GitLab CI, etc.) where Firebase emulators are required for integration or end-to-end tests.

Typical usage:

- Start container
- Run tests against emulator endpoints
- Stop container

---

## License

MIT

---

## Disclaimer

This project is not officially affiliated with Firebase or Google.
Firebase is a trademark of Google LLC.
