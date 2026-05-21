```
██████╗░███████╗██████╗░░░░░░░░█████╗░██╗░░░██╗████████╗░█████╗░
██╔══██╗██╔════╝██╔══██╗░░░░░░██╔══██╗██║░░░██║╚══██╔══╝██╔══██╗
██║░░██║█████╗░░██████╦╝█████╗███████║██║░░░██║░░░██║░░░██║░░██║
██║░░██║██╔══╝░░██╔══██╗╚════╝██╔══██║██║░░░██║░░░██║░░░██║░░██║
██████╔╝███████╗██████╦╝░░░░░░██║░░██║╚██████╔╝░░░██║░░░╚█████╔╝
╚═════╝░╚══════╝╚═════╝░░░░░░░╚═╝░░╚═╝░╚═════╝░░░░╚═╝░░░░╚════╝░
```

# alsosram-deb-auto

Debian setup script that auto-detects the first non-root user and configures sudo, Curl, Cockpit, and SSH.

## What It Installs

- `sudo`
- `net-tools`
- `curl`
- `cockpit`
- `openssh-server` (if not already present)

It also creates a sudoers rule for the detected user (or the one passed as an argument):

```text
<username> ALL=(ALL:ALL) ALL
```

The script writes this rule to `/etc/sudoers.d/<username>` and validates it with `visudo` instead of editing `/etc/sudoers` directly.

It also configures NetworkManager so Cockpit can manage ifupdown interfaces by setting this in `/etc/NetworkManager/NetworkManager.conf`:

```ini
[ifupdown]
managed=true
```

The original NetworkManager config is backed up to `/etc/NetworkManager/NetworkManager.conf.bak` before editing.

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
