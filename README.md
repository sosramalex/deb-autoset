# Debian Bootstrap Installer

A small Debian setup script for installing common administration tools and granting sudo access to a user.

## What It Installs

- `sudo`
- `net-tools`
- `curl`
- `cockpit`

It also creates a sudoers rule for `asosar` by default:

```text
asosar ALL=(ALL:ALL) ALL
```

The script writes this rule to `/etc/sudoers.d/asosar` and validates it with `visudo` instead of editing `/etc/sudoers` directly.

It also configures NetworkManager so Cockpit can manage ifupdown interfaces by setting this in `/etc/NetworkManager/NetworkManager.conf`:

```ini
[ifupdown]
managed=true
```

The original NetworkManager config is backed up to `/etc/NetworkManager/NetworkManager.conf.bak` before editing.

## Usage

On a fresh Debian system, run as `root`:

```bash
su -
bash debian-bootstrap.sh
```

To configure sudo for a different user:

```bash
su -
bash debian-bootstrap.sh your_username
```

## Download And Run From GitHub

After this project is pushed to GitHub, you can run it on Debian like this:

```bash
curl -fsSL https://raw.githubusercontent.com/asosar2195/debian-bootstrap-installer/main/debian-bootstrap.sh -o debian-bootstrap.sh
bash debian-bootstrap.sh
```

## Publish With GitHub Desktop

1. Open GitHub Desktop.
2. Choose **File > Add local repository**.
3. Select this folder.
4. If GitHub Desktop says it is not a Git repository yet, choose **Create a repository**.
5. Commit the files.
6. Click **Publish repository**.
