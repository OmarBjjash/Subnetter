#!/usr/bin/env bash
# ---------------------------------------------------------------
# Subnetter installer
# Installs the app, icons, and desktop launcher for the current user.
# ---------------------------------------------------------------
set -euo pipefail

APP_NAME="subnetter"
APP_DISPLAY_NAME="Subnetter"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor"
DESKTOP_FILE="$APP_DIR/${APP_NAME}.desktop"
SCRIPT_SRC="$PROJECT_DIR/$APP_NAME"
ICON_ROOT="$PROJECT_DIR/icons/desktop"

# ---- Sanity checks -------------------------------------------------
if [[ ! -f "$SCRIPT_SRC" ]]; then
  echo "Error: '$SCRIPT_SRC' not found. Run install.sh from the project root." >&2
  exit 1
fi

if [[ ! -d "$ICON_ROOT" ]]; then
  echo "Error: '$ICON_ROOT' not found. Missing icons/desktop/." >&2
  exit 1
fi

# ---- Install executable -------------------------------------------
echo "→ Installing executable to $BIN_DIR/$APP_NAME"
mkdir -p "$BIN_DIR"
install -m 0755 "$SCRIPT_SRC" "$BIN_DIR/$APP_NAME"

# ---- Install icons -------------------------------------------------
echo "→ Installing icons to $ICON_DIR"
for size_dir in "$ICON_ROOT"/*/; do
  size="$(basename "$size_dir")" # e.g. 256x256
  src="$size_dir/${APP_NAME}.png"
  [[ -f "$src" ]] || continue
  dest="$ICON_DIR/$size/apps"
  mkdir -p "$dest"
  install -m 0644 "$src" "$dest/${APP_NAME}.png"
  echo "   • $size"
done

# ---- Create .desktop launcher -------------------------------------
echo "→ Writing launcher to $DESKTOP_FILE"
mkdir -p "$APP_DIR"
cat >"$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=$APP_DISPLAY_NAME
Comment=Calculate subnets, host ranges, and usable IPs from an IP/CIDR
Exec=$BIN_DIR/$APP_NAME
Icon=$APP_NAME
StartupWMClass=$APP_NAME
Terminal=false
Categories=Network;Utility;
Keywords=subnet;ip;cidr;network;calculator;
StartupNotify=true
EOF
chmod 0644 "$DESKTOP_FILE"

# ---- Refresh caches ------------------------------------------------
echo "→ Refreshing caches"
update-desktop-database "$APP_DIR" 2>/dev/null || true
gtk-update-icon-cache -f -t "$ICON_DIR" 2>/dev/null || true

# ---- PATH hint -----------------------------------------------------
if ! echo ":$PATH:" | grep -q ":$BIN_DIR:"; then
  echo
  echo "Note: $BIN_DIR is not in your PATH."
  echo "Add this to ~/.bashrc and re-login:"
  echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo
echo "✔ Subnetter installed."
echo "  Run it from your app menu, or launch: $BIN_DIR/$APP_NAME"
echo
echo "  If the dock icon does not appear, log out and back in"
echo "  (GNOME caches window-to-launcher mappings per session)."
