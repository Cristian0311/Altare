# Isla Eterna Online — Altare deployment

This repository is being prepared to build and deploy the dedicated Godot server for Altare.

## Current status

- Altare server: `th-bkk03.altare.global:25571`
- Altare container currently uses Node.js 20 and its startup command expects `index.js`/TypeScript. That is not the Godot server and currently crashes with `Cannot find module './index.js'`.
- The Godot source project is **not yet present in this repository**. Do not change Altare's startup command until the project and Linux server build are added and validated.
- ENet requires UDP. The Altare assignment's protocol still needs confirmation; a hostname and port alone do not prove UDP is enabled.

## Safe deployment plan

1. Add the complete Godot project source (including `project.godot`, scenes, scripts, and any assets) to this repository.
2. Validate the project with the matching Godot 4.x headless editor and resolve parse/import errors.
3. Configure a reproducible Linux dedicated-server export and archive it as a build artifact.
4. Confirm Altare supports a custom executable/start command and UDP on the assigned port.
5. Upload the verified build, configure `SERVER_PORT=25571` only if Altare confirms that port is UDP, then inspect console logs and test a real client connection.

## Important

Do not commit passwords, SFTP credentials, tokens, or private keys. Do not treat a successful workflow or ZIP creation as proof that the server is running; the final validation is a successful Godot startup and ENet client connection.