# Changelog

## 0.2.0 — 2026-10-21

Devices need firmware that speaks relay protocol v2 and the sealed LAN hop (the ESP-IDF firmware, not yet released); older firmware gets `403` from this bridge on the LAN.

### Changed

- **Breaking.** The bridge token is read only from `Authorization: Bearer <token>`. The `?token=` query parameter and the JSON body `token` field are gone, with no fallback. Removes token exposure in URL query strings and logs.
- 17 dependencies updated in one group, including `axum` 0.7.9 to 0.8.9, `chacha20poly1305` 0.10.1 to 0.11.0, `tokio-tungstenite` 0.24.0 to 0.30.0, `toml` 0.8.23 to 1.1.6, and `rustls` 0.23.41 to 0.23.45. The dependency bump itself left relay-mode encryption unchanged on the wire.
- A new `/codex/exec` stops a run still in progress instead of running beside it.
- **Breaking.** Relay mode speaks a new end-to-end protocol, and the device must run matching firmware. The relay gets a route id derived from `BRIDGE_TOKEN` instead of the token, each message is bound to its method and direction and each reply chunk to its request, and requests run only inside a session the bridge issues.
- **Breaking.** `BRIDGE_TOKEN` must be at least 32 bytes, and the bridge refuses to start with a shorter one. Generate one with `openssl rand -hex 32` and set the same value on the device.
- Relay replies to `/ask` end with `{done, stop_reason}` and no longer repeat the whole reply as `text`.
- **Breaking.** Another machine can reach only the new sealed routes, `POST /sealed/ask`, `/sealed/codex_exec` and `/sealed/codex_status`; every plaintext route answers it `403`, even with the right token. Loopback callers keep the plaintext API. The device must run matching firmware.
- **Breaking.** `BRIDGE_TLS`, or `[tls]` with `enabled = true`, makes the bridge refuse to start. It used to warn and serve plain HTTP.
- `rcgen` and `rustls-pemfile` are gone, taking 25 crates out of `Cargo.lock`; `ring` and `time` are no longer built.

### Added

- `CODEX_WORKDIR` / `[codex] workdir`: the directory `/codex/exec` runs Codex in, passed as `-C`. Codex refuses to run outside a git repository or a trusted directory, which a service-managed bridge's working directory usually isn't.

### Fixed

- `Cargo.lock` was missing the TLS crates its manifest declares, so every `--locked` build failed before compiling — including the release cross-compile.
- `/codex/exec` works again. The bridge passed `--approval-policy=`, a flag `codex exec` doesn't have, so every run exited 2. The policy now travels as `-c approval_policy="…"`.
- Replies longer than about 2 KB reach the device. A whole reply arrived as one `delta` line, and the device drops any line over 2 KiB; deltas are now at most 256 bytes.
- `/codex/status` fits the device's 4 KB read. Event text is capped at 150 bytes, and event timestamps strictly increase so `since` never skips one.
- A `claude` run is killed as soon as the caller disconnects, and after 10 minutes at most. `claude` and `codex` get a null stdin.
- OTLP token and cost figures are totals since the bridge started. They showed only the last data point of the latest export.
- `--enable-autostart` carries `--config` into the service, quotes and escapes paths for systemd, launchd and Task Scheduler, re-registers cleanly when run twice, writes the Windows task in the UTF-16 it declares, and lifts Task Scheduler's 72-hour run limit.
- `/otlp/status` reads the token from `Authorization: Bearer` like every other route. It still read `?token=`.
- Relay requests after the first on a connection work. The bridge kept one replay counter per connection while the device starts a new one per request, so it rejected every later request, and requests read back to back were checked out of order.
- A dead relay connection is redialed. The connect times out after 15 seconds, the bridge pings every 20 seconds, and it drops a connection that sends nothing for 60 seconds. A half-open socket after a NAT timeout or laptop sleep used to leave relay mode dead until restart.

### Security

- The relay never receives `BRIDGE_TOKEN`. It used to get the raw token in the connect header and every device request and keep it in its Valkey keys, and the encryption key derives from the token, so whoever ran the relay or read Valkey could decrypt and forge all relay traffic, `/ask` and `/codex/exec` included. It now gets a route id it can't turn into the key.
- Relay messages are bound to their method and direction, so the relay can't re-send a chat prompt as a `/codex/exec` run or reflect a reply back as a request. Reply chunks are bound to their request and position, so they can't be spliced, reordered or cut short unnoticed.
- Relay replay protection survives reconnects. A request runs only under a live bridge-issued session, which lasts a fixed 10 minutes, with a counter above the last one accepted. The old per-connection counter reset whenever the relay forced a reconnect.
- A loopback request from a web page or through a proxy needs `BRIDGE_TOKEN`, like a LAN caller. Before this, any page in the browser could start `claude` or `codex` through the no-token loopback path, and a DNS-rebinding page could read the results. Point local tools at `localhost`.
- A prompt can no longer be parsed as a `claude` option; it now follows `--`, as it already did for `codex`.
- On the LAN the bridge token no longer crosses the network. The device sent it as `Authorization: Bearer` over plain HTTP, so anyone on the same Wi-Fi could read it and then run `claude` and `codex` on this machine. LAN requests and replies are now sealed end to end like relay traffic, under a key derived from the token and bound to method, direction, request and a bridge-issued session, and they are admitted against the relay's session table, so a request runs at most once whichever path delivers it.

## 0.1.6 — 2026-07-11

### Fixed

- The Codex run total no longer caps at five. It was derived from the 5-entry recent-activity trail, so any run with more than five tool calls reported `total=5`; it now counts every `item.*` event for the run.

## 0.1.5 — 2026-07-10

### Added

- The OTLP receiver accepts `application/json` on `/v1/logs` and `/v1/metrics` alongside protobuf, dispatching on `Content-Type`.

## 0.1.4 — 2026-07-10

### Added

- Opt-in OTLP receiver for Claude Code and Codex CLI telemetry — `/v1/logs`, `/v1/metrics` and `GET /otlp/status`, off by default.
- Optional `LOOPBACK_TOKEN`.

### Changed

- **Breaking.** Default `BRIDGE_PORT` moves from 8787 to 4318, with one listener serving both the device API and OTLP.

### Fixed

- `/ask` works against current Claude Code CLIs again: `--verbose` is now passed with `-p --output-format stream-json`, without which every call exited non-zero.
- stderr is drained concurrently with stdout, so a chatty subprocess can no longer fill the stderr pipe and deadlock the stream.

### Security

- Authentication depends on connection origin: a LAN caller always needs `BRIDGE_TOKEN`, on every endpoint including `/health`, which was previously unauthenticated.

## 0.1.3 — 2026-07-10

### Added

- `--enable-autostart` and `--disable-autostart`, registering the binary with the OS service manager: systemd `--user` with lingering on Linux, a LaunchAgent on macOS, a hidden Task Scheduler task on Windows. The macOS and Windows paths are unverified against real hardware.

## 0.1.2 — 2026-07-09

### Added

- `brew services start aiteru-bridge` works, via a `service do` block in the generated Formula.
- The tap ships a real README, LICENSE and NOTICES.

### Changed

- Crate license metadata moves from `Apache-2.0` to the proprietary `license-file`.

### Fixed

- The startup banner and crate metadata no longer call the device StackChan. Aiteru is an independent device.

## 0.1.1 — 2026-07-08

First published release. No in-crate change from the 0.1.0 tag state; the fix was in the release workflow, which now seeds the tap's first commit before creating the release.

## 0.1.0 — tagged 2026-07-08, never published

The Releases API rejected it against an empty repository, so no artifacts exist for this version.

### Added

- The Rust implementation, on axum and tokio, replacing the Python server.
- A TOML config file, with `--config <path>`, and environment variables taking precedence over the file.
- Opt-in relay mode: HKDF-SHA256 key derivation from `BRIDGE_TOKEN`, ChaCha20-Poly1305 with a fresh nonce per message, and an outbound `wss://` tunnel client. A bridge that never enables it keeps direct LAN-only connectivity.

### Changed

- The bridge no longer handles license activation; it serves `/ask`, `/codex/exec`, `/codex/status` and `/health` only.
