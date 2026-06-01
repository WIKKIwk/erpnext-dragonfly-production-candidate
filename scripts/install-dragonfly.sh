#!/usr/bin/env bash
set -euo pipefail

# Install Dragonfly from the official GitHub release assets.
#
# This script intentionally downloads Dragonfly from upstream instead of
# redistributing the binary in this repository.

VERSION="${DRAGONFLY_VERSION:-latest}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing command: $1" >&2
    exit 1
  }
}

require_cmd curl
require_cmd tar

arch="$(uname -m)"
case "$arch" in
  x86_64 | amd64)
    asset_arch="x86_64"
    ;;
  aarch64 | arm64)
    asset_arch="aarch64"
    ;;
  *)
    echo "Unsupported architecture: $arch" >&2
    exit 1
    ;;
esac

if [ "$VERSION" = "latest" ]; then
  api_url="https://api.github.com/repos/dragonflydb/dragonfly/releases/latest"
else
  api_url="https://api.github.com/repos/dragonflydb/dragonfly/releases/tags/$VERSION"
fi

echo "Resolving Dragonfly release: $VERSION"
release_json="$TMP_DIR/release.json"
curl -fsSL "$api_url" -o "$release_json"

asset_url="$(
  sed -n 's/.*"browser_download_url": "\(.*\)".*/\1/p' "$release_json" \
    | grep -E "dragonfly.*${asset_arch}.*\.(tar\.gz|tgz)$" \
    | head -n 1
)"

if [ -z "$asset_url" ]; then
  echo "Could not find a Dragonfly ${asset_arch} tarball in release assets." >&2
  echo "Install Dragonfly manually from https://github.com/dragonflydb/dragonfly/releases" >&2
  exit 1
fi

mkdir -p "$INSTALL_DIR"
archive="$TMP_DIR/dragonfly.tar.gz"

echo "Downloading: $asset_url"
curl -fL "$asset_url" -o "$archive"

tar -xzf "$archive" -C "$TMP_DIR"

dragonfly_bin="$(
  find "$TMP_DIR" -type f -perm -111 \( -name 'dragonfly' -o -name 'dragonfly-*' -o -name 'dragonfly_*' \) \
    | head -n 1
)"

if [ -z "$dragonfly_bin" ]; then
  echo "Dragonfly binary was not found inside the release archive." >&2
  exit 1
fi

install -m 0755 "$dragonfly_bin" "$INSTALL_DIR/dragonfly"

echo "Installed Dragonfly to $INSTALL_DIR/dragonfly"
echo
"$INSTALL_DIR/dragonfly" --version || true
echo
echo "Make sure $INSTALL_DIR is in PATH before running the ERPNext Dragonfly scripts."
