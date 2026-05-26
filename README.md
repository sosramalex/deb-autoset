```
██████╗░███████╗██████╗░░░░░░░░█████╗░██╗░░░██╗████████╗░█████╗░
██╔══██╗██╔════╝██╔══██╗░░░░░░██╔══██╗██║░░░██║╚══██╔══╝██╔══██╗
██║░░██║█████╗░░██████╦╝█████╗███████║██║░░░██║░░░██║░░░██║░░██║
██║░░██║██╔══╝░░██╔══██╗╚════╝██╔══██║██║░░░██║░░░██║░░░██║░░██║
██████╔╝███████╗██████╦╝░░░░░░██║░░██║╚██████╔╝░░░██║░░░╚█████╔╝
╚═════╝░╚══════╝╚═════╝░░░░░░░╚═╝░░╚═╝░╚═════╝░░░░╚═╝░░░░╚════╝░
```

# alsosram-deb-auto

Debian setup script that auto-detects the first non-root user and configures sudo, curl, SSH, dynamically displays the IP address at the login prompt, and optionally enables NetworkManager ifupdown management.

## What It Installs / Configures

- `sudo` + sudoers rule for the detected user
- `net-tools`
- `curl`
- `openssh-server` (if not already present)
- **IP login banner** — `/etc/issue` is auto-generated with the current primary IP address, updated at boot and on every network change
- **NetworkManager** `managed=true` for ifupdown interfaces (when NM is present)

It creates a sudoers rule for the detected user (or the one passed as an argument):

```text
<username> ALL=(ALL:ALL) ALL
```

The script writes this rule to `/etc/sudoers.d/<username>` and validates it with `visudo` instead of editing `/etc/sudoers` directly.

It optionally sets `managed=true` in `/etc/NetworkManager/NetworkManager.conf` (backed up to `.bak`).

## IP Login Banner

Instead of Cockpit, the script installs a lightweight mechanism to show the server's IP address at the login prompt:

- **`/usr/local/bin/generate-issue.sh`** — detects all non-loopback IPv4 addresses and their interfaces, writes `/etc/issue`
- **`generate-issue.service`** — a systemd oneshot unit that runs after the network is online at boot
- **`/etc/NetworkManager/dispatcher.d/99-update-issue`** — a NetworkManager dispatcher that re-generates `/etc/issue` whenever a connection comes up, keeping the login prompt current

**OpenMediaVault note:** If OMV is detected (`/etc/openmediavault/config.xml`), the IP banner setup is skipped entirely, as OVM manages its own login banner.

## Usage

On a fresh Debian system with a non-root user already created, run as `root`:

```bash
su -
bash install.sh
```

The script will automatically detect the first non-root user (UID >= 1000). To override:

```bash
su -
bash install.sh your_username
```

## Download And Run From GitHub

```bash
curl -fsSL https://raw.githubusercontent.com/alsosram/deb-auto/main/install.sh -o install.sh
bash install.sh
```
