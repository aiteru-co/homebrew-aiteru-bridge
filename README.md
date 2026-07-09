# aiteru-bridge

A lightweight relay binary that tunnels requests from a small or remote device to Claude Code and Codex CLI sessions running on a full computer.

## How It Works

`aiteru-bridge` runs on a computer that has Claude Code and/or the Codex CLI installed and authenticated. It exposes a small HTTP API that a remote device can call to send prompts and receive streamed replies, without the device ever needing its own API key or running the CLIs itself. Two connectivity modes are supported:

- **Direct (LAN or VPN mesh)**: the device reaches the bridge directly over the local network, or over a mesh VPN that routes like an extended LAN rather than a standard single-exit-node VPN — recommended: NordVPN Meshnet or Tailscale.
- **Relay (opt-in)**: the bridge dials out to a hosted relay over an authenticated, end-to-end encrypted WebSocket tunnel, so the device can reach it without port-forwarding or a static IP. The relay only ever forwards opaque encrypted envelopes — it never holds the key or sees message contents.

Every request must carry a shared secret token; requests without a valid token are rejected before any CLI process is spawned.

## Installation

**macOS**, and **Linux with Homebrew/Linuxbrew** installed:

```sh
brew install aiteru-co/aiteru-bridge/aiteru-bridge
```

**Linux without Homebrew:**

1. Download `aiteru-bridge-<version>-linux-x86_64.tar.gz` from the [releases page](https://github.com/aiteru-co/homebrew-aiteru-bridge/releases).
2. Extract it and place the binary on your `PATH`:
   ```sh
   tar -xzf aiteru-bridge-*-linux-x86_64.tar.gz
   sudo mv aiteru-bridge /usr/local/bin/
   ```

**Windows** (no Homebrew build exists for this platform):

1. Download `aiteru-bridge-<version>-windows-x86_64.zip` from the [releases page](https://github.com/aiteru-co/homebrew-aiteru-bridge/releases).
2. Extract `aiteru-bridge.exe` to a folder of your choice.

## Usage

Pick a shared secret token — any random high-entropy string works, there's nothing to sign up for or retrieve from anywhere. Generate one:

```sh
# macOS / Linux
openssl rand -hex 32
```

```powershell
# Windows PowerShell
-join ((1..32) | ForEach-Object { '{0:x2}' -f (Get-Random -Max 256) })
```

Then run:

```sh
BRIDGE_TOKEN=<the-token-you-generated> aiteru-bridge
```

```powershell
# Windows
$env:BRIDGE_TOKEN="<the-token-you-generated>"; .\aiteru-bridge.exe
```

The bridge binds all network interfaces on port `8787` by default: `http://localhost:8787` from the same machine, or `http://<this-machine's-LAN-IP>:8787` from another device on the network. Confirm it's up:

```sh
curl http://localhost:8787/health
```

Whatever token you generated must also be set on the device (or client) you're pointing at this bridge — check that device's own setup instructions for where its matching token setting lives.

Endpoints:

- `POST /ask` — one-shot prompt/reply against Claude Code, streamed as newline-delimited JSON.
- `POST /codex/exec` — queues a Codex CLI run; poll `/codex/status` for progress.
- `GET /codex/status` — polls a queued Codex run.
- `GET /health` — health check.

## Configuration

Settings can live in a TOML file instead of an environment variable, useful when running the bridge continuously in the background.

Default location:

- Linux: `$XDG_CONFIG_HOME/aiteru-bridge/config.toml`, or `~/.config/aiteru-bridge/config.toml` if unset
- macOS: `~/Library/Application Support/aiteru-bridge/config.toml`
- Windows: `%APPDATA%\aiteru-bridge\config\config.toml`

Override with `--config <path>`. A missing file is not an error; a present-but-malformed file causes the bridge to refuse to start rather than silently ignore a typo.

```toml
port = 8787
token = "your-shared-secret"

[relay]
enabled = true
host = "relay.example.com"
chip_id = "a1b2c3d4e5f6"
```

| Setting | Env var | Default | Notes |
|---|---|---|---|
| `port` | `BRIDGE_PORT` | `8787` | |
| `token` | `BRIDGE_TOKEN` | none (required) | Bridge refuses to start without one set. |
| `relay.enabled` | `RELAY_ENABLED` | `false` | Opt-in outbound tunnel; direct LAN mode otherwise. |
| `relay.host` | `RELAY_HOST` | none | Required if relay is enabled. |
| `relay.chip_id` | `RELAY_CHIP_ID` | none | Required if relay is enabled; identifies this bridge instance to the relay. |

Environment variables always override the config file when both set a value.

## Starting Automatically

By default, `aiteru-bridge` only runs while its terminal session is open. Set up the config file above (with at least `token` set) before doing any of the below — none of these methods pass environment variables for you.

**macOS / Linux, via Homebrew:**

```sh
brew services start aiteru-bridge
```

Stop with `brew services stop aiteru-bridge`. Logs go to `$(brew --prefix)/var/log/aiteru-bridge.log`.

**Linux without Homebrew**, using a systemd user service:

1. Create `~/.config/systemd/user/aiteru-bridge.service`:
   ```ini
   [Unit]
   Description=aiteru-bridge relay

   [Service]
   ExecStart=/usr/local/bin/aiteru-bridge
   Restart=on-failure

   [Install]
   WantedBy=default.target
   ```
2. Enable and start it:
   ```sh
   systemctl --user daemon-reload
   systemctl --user enable --now aiteru-bridge
   ```
3. So it keeps running after you log out, not just while a session is open:
   ```sh
   loginctl enable-linger $USER
   ```

**Windows**, via Task Scheduler (runs hidden — no console window pops up):

1. Open Task Scheduler (`Win+R` → `taskschd.msc`) → **Create Task** (not "Create Basic Task").
2. **General** tab: name it, select **Run whether user is logged on or not**, and check **Hidden**.
3. **Triggers** tab → **New** → **At log on**, for your user account.
4. **Actions** tab → **New** → **Start a program** → browse to `aiteru-bridge.exe`.
5. Save; enter your account password when prompted (required for "run whether logged on or not").

## Security

- Every request requires the shared token; token comparison is constant-time to avoid leaking partial matches via response timing.
- Bind the direct-connection port to a trusted LAN only; use relay mode (or your own TLS-terminating proxy) for any off-LAN reachability.
- The bridge strips any `ANTHROPIC_API_KEY` from the environment it hands to child processes, so Claude Code always authenticates via the logged-in subscription rather than pay-per-use API billing.

## License

See [LICENSE](LICENSE). Third-party components are listed in [NOTICES](NOTICES).
