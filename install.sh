#!/usr/bin/env bash
set -euo pipefail

show_banner() {
  echo "    _    _     ____   ___  ____    _    ____       ____  _____ ____          _   _   _ _____ ___  "
  echo "   / \  | |   / ___| / _ \/ ___|  / \  |  _ \     |  _ \| ____| __ )        / \ | | | |_   _/ _ \ "
  echo "  / _ \ | |   \___ \| | | \___ \ / _ \ | |_) |____| | | |  _| |  _ \ _____ / _ \| | | | | || | | |"
  echo " / ___ \| |___ ___) | |_| |___) / ___ \|  _ <_____| |_| | |___| |_) |_____/ ___ \ |_| | | || |_| |"
  echo "/_/   \_\_____|____/ \___/|____/_/   \_\_| \_\    |____/|_____|____/     /_/   \_\___/  |_| \___/ "
  echo ""
  echo "         Debian Auto-Installer — Sudo, Cockpit, SSH & Tools"
  echo ""
}

show_banner

detect_nonroot_user() {
  getent passwd | awk -F: '$3 >= 1000 && $3 < 65534 { print $1; exit }'
}

if [[ $# -ge 1 ]]; then
  SUDO_USER_NAME="$1"
else
  SUDO_USER_NAME=$(detect_nonroot_user) || true
  if [[ -z "$SUDO_USER_NAME" ]]; then
    echo "No non-root user detected. Please provide a username:"
    echo "  bash $0 <username>"
    exit 1
  fi
fi

SUDOERS_FILE="/etc/sudoers.d/${SUDO_USER_NAME}"
NETWORKMANAGER_CONF="/etc/NetworkManager/NetworkManager.conf"
PACKAGES=(sudo net-tools curl cockpit)

configure_networkmanager_ifupdown() {
  if [[ ! -f "${NETWORKMANAGER_CONF}" ]]; then
    echo "NetworkManager config not found at ${NETWORKMANAGER_CONF}; skipping ifupdown management."
    return
  fi

  cp "${NETWORKMANAGER_CONF}" "${NETWORKMANAGER_CONF}.bak"

  awk '
    BEGIN {
      in_section = 0
      saw_section = 0
      wrote_managed = 0
    }
    /^\[ifupdown\][[:space:]]*$/ {
      if (in_section && !wrote_managed) {
        print "managed=true"
      }
      print
      in_section = 1
      saw_section = 1
      wrote_managed = 0
      next
    }
    /^\[/ {
      if (in_section && !wrote_managed) {
        print "managed=true"
      }
      in_section = 0
    }
    in_section && /^[[:space:]]*managed[[:space:]]*=/ {
      print "managed=true"
      wrote_managed = 1
      next
    }
    { print }
    END {
      if (in_section && !wrote_managed) {
        print "managed=true"
      }
      if (!saw_section) {
        print ""
        print "[ifupdown]"
        print "managed=true"
      }
    }
  ' "${NETWORKMANAGER_CONF}.bak" > "${NETWORKMANAGER_CONF}"
}

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run this script as root:"
  echo "  su -"
  echo "  bash $0 ${SUDO_USER_NAME}"
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This script is intended for Debian-based systems with apt-get."
  exit 1
fi

if ! id "${SUDO_USER_NAME}" >/dev/null 2>&1; then
  echo "User '${SUDO_USER_NAME}' does not exist. Create the user first or pass a different username:"
  echo "  bash $0 your_username"
  exit 1
fi

echo "Updating package lists..."
apt-get update

echo "Installing packages: ${PACKAGES[*]}"
DEBIAN_FRONTEND=noninteractive apt-get install -y "${PACKAGES[@]}"

echo "Granting sudo access to '${SUDO_USER_NAME}'..."
printf '%s ALL=(ALL:ALL) ALL\n' "${SUDO_USER_NAME}" > "${SUDOERS_FILE}"
chmod 0440 "${SUDOERS_FILE}"

if ! visudo -cf "${SUDOERS_FILE}"; then
  echo "Invalid sudoers file generated. Removing ${SUDOERS_FILE}."
  rm -f "${SUDOERS_FILE}"
  exit 1
fi

if command -v systemctl >/dev/null 2>&1; then
  echo "Enabling Cockpit socket..."
  systemctl enable --now cockpit.socket

  echo "Checking SSH server..."
  if ! dpkg -l openssh-server >/dev/null 2>&1; then
    echo "Installing openssh-server..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server
  fi
  systemctl enable --now ssh

  echo "Configuring NetworkManager to manage ifupdown interfaces..."
  configure_networkmanager_ifupdown

  if systemctl cat NetworkManager.service >/dev/null 2>&1; then
    echo "Restarting NetworkManager..."
    systemctl restart NetworkManager
  else
    echo "NetworkManager service not found; config was updated but service was not restarted."
  fi
else
  echo "systemctl not found; Cockpit was installed but not enabled automatically."
fi

echo "Done."
echo "Installed: ${PACKAGES[*]}"
echo "SSH server: enabled"
echo "Sudo access configured for: ${SUDO_USER_NAME}"
echo "NetworkManager ifupdown managed=true configured when available."
