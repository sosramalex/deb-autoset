<p align="center">
  <img src="https://placehold.co/120x179" width="90" alt="deb-autoset logo">
  <!-- Replace src with your 784×1168 logo image (displayed at 90px wide) -->
</p>

[![GitHub](https://img.shields.io/static/v1?label=GitHub&message=sosaramosalexis%2Fdeb-autoset&color=181717&logo=github)](https://github.com/sosaramosalexis/deb-autoset)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-blue?logo=gnu-bash)]()
[![Platform](https://img.shields.io/badge/platform-Linux-blue)]()

```
██████╗░███████╗██████╗░░░░░░░░█████╗░██╗░░░██╗████████╗░█████╗░
██╔══██╗██╔════╝██╔══██╗░░░░░░██╔══██╗██║░░░██║╚══██╔══╝██╔══██╗
██║░░██║█████╗░░██████╦╝█████╗███████║██║░░░██║░░░██║░░░██║░░██║
██║░░██║██╔══╝░░██╔══██╗╚════╝██╔══██║██║░░░██║░░░██║░░░██║░░██║
██████╔╝███████╗██████╦╝░░░░░░██║░░██║╚██████╔╝░░░██║░░░╚█████╔╝
╚═════╝░╚══════╝╚═════╝░░░░░░░╚═╝░░╚═╝░╚═════╝░░░░╚═╝░░░░╚════╝░
```

# sosaramosalexis-deb-autoset

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

**OpenMediaVault note:** The script prompts whether this is an OMV system (via whiptail, or text fallback). If confirmed, the IP banner setup is skipped since OMV manages its own login banner. Auto-detection via `/etc/openmediavault/config.xml` is used if whiptail is unavailable and stdin is non-interactive.

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
curl -fsSL https://raw.githubusercontent.com/sosaramosalexis/deb-autoset/main/install.sh -o install.sh
bash install.sh
```
