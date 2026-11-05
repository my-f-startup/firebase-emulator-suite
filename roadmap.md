# Roadmap

Work planned for this tooling, driven by the my-f-startup reference architecture (local development and tests).

Legend: Done, Partial, Open.

| Item | Status | Evidence and note |
|---|---|---|
| Docker image with Auth, Firestore, Realtime Database, Pub/Sub and the UI | Done | `firebase.json`, `docker-compose.yml` and the readme |
| Publish a small helper to start the container, expose the ports and reset Auth, Firestore and Realtime Database between tests | Open | Not found. Dependent repositories start the image with Testcontainers on their own. A shared helper removes that repetition |
