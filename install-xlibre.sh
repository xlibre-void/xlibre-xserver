#!/bin/sh

# Maintainer : Sofiya for XLibre (sofiya@xlibre-void)
# Script     : install-xlibre.sh
# Version    : 0.1.3-local
#
# Note: this script requires 'sudo' to perform the installation.
# It is designed to be run directly on a live Void Linux system.

set -e # Останавливать выполнение при любой ошибке

# Проверка прав root (или наличия sudo)
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or with sudo." >&2
    exit 1
fi

echo "Detecting architecture..."
ARCH=$(uname -m)

case "$ARCH" in
	aarch64)
		REPO_SUFFIX="repository-aarch64"
		CONF_FILE="/etc/xbps.d/99-repository-aarch64.conf"
		KEY_FILE="00:ca:42:57:c9:c0:9a:ec:94:b4:7d:97:e5:a9:aa:1e.plist"
		;;
	aarch64-musl)
		REPO_SUFFIX="repository-aarch64-musl"
		CONF_FILE="/etc/xbps.d/99-repository-aarch64-musl.conf"
		KEY_FILE="00:ca:42:57:c9:c0:9a:ec:94:b4:7d:97:e5:a9:aa:1e.plist"
		;;
	armv7l)
		REPO_SUFFIX="repository-armv7l"
		CONF_FILE="/etc/xbps.d/99-repository-armv7l.conf"
		KEY_FILE="00:ca:42:57:c9:c0:9a:ec:94:b4:7d:97:e5:a9:aa:1e.plist"
		;;
	armv6l-musl)
		REPO_SUFFIX="repository-armv6l-musl"
		CONF_FILE="/etc/xbps.d/99-repository-armv6l-musl.conf"
		KEY_FILE="00:ca:42:57:c9:c0:9a:ec:94:b4:7d:97:e5:a9:aa:1e.plist"
		;;
	*)
		echo "Error: Unsupported architecture $ARCH" >&2
		exit 1
		;;
esac

REPO_URL="https://github.com/xlibre-void/xlibre-xserver/releases/download/${REPO_SUFFIX}"
KEY_URL="https://github.com/xlibre-void/xlibre/raw/refs/heads/main/repo-keys/x86_64/${KEY_FILE}"

echo "Architecture detected: ${ARCH}"
echo "Configuring repository: ${REPO_URL}"

# 1. Create directory if it doesn't exist
mkdir -p /etc/xbps.d

# 2. Write config file atomically
cat > "${CONF_FILE}" <<EOF
repository=${REPO_URL}
EOF

# 3. Import public key safely
echo "Importing signing key..."
if command -v xbps-rkeys >/dev/null 2>&1; then
    # Рекомендуемый способ в Void Linux
    xbps-rkeys --add-key-from-url "${KEY_URL}" --force
else
    # Fallback, если утилита отсутствует в минимальной установке
    wget -O "/var/db/xbps/keys/${KEY_FILE}" "${KEY_URL}"
fi

# 4. Update database and install package
echo "Updating package index..."
xbps-install -Su

echo "Installing xlibre metapackage..."
xbps-install -y xlibre

echo ""
echo "=========================================="
echo "XLibre has been installed successfully."
echo "You may need to reboot or restart your display manager."
echo "=========================================="
