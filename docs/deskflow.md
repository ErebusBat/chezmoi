# Deskflow

Set machine-specific values in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data.deskflow]
mode = "server" # server, client, or disabled (default)
server = ""     # On clients, use the server's reachable hostname or IP.
```

The init template preserves these values. Machines without this section default
to disabled. Only the exact mode `server` deploys the server configuration:

| Platform | File |
| --- | --- |
| macOS | `~/Library/Deskflow/deskflow-server.conf` |
| Linux | `~/.config/Deskflow/deskflow-server.conf` |

The shared source is `.chezmoitemplates/deskflow-server.conf`. It preserves the
working desk layout: `dartp6` above `USMB-JVK937H909`, with Hyper+F16 cycling
computers. QMK: `HYPR(KC_F16)`. Review the screen names and links before using
this layout on a different server; mode alone does not rename the screens.

In the server GUI, select external configuration and the path above. Confirm
the startup log's `core config file` matches: older installs or custom launches
can use a different configuration directory.

Client mode does not deploy a server layout. The `server` field records the
client connection address; enter it in the Deskflow client GUI. It does not yet
rewrite GUI settings or start a client process.

Disabled (and unknown modes) means chezmoi does not deploy this configuration.
It does not delete an existing file, stop Deskflow, or uninstall it. Stop or
reconfigure the app explicitly when changing roles.

GUI preferences, TLS private keys, certificates, trust lists, permissions, and
autostart are intentionally machine-local and unmanaged. Keep TLS enabled and
verify peer fingerprints when pairing. No package installation is added here.

Preview only the server file with `chezmoi diff <path>`. A full `chezmoi apply`
can run unrelated workstation scripts and automatically commit/push changes.
