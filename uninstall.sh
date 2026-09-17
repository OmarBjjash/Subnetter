#!/usr/bin/env bash
set -euo pipefail
APP_NAME="subnetter"

rm -f "$HOME/.local/bin/$APP_NAME"
rm -f "$HOME/.local/share/applications/$APP_NAME.desktop"
rm -f "$HOME"/.local/share/icons/hicolor/*/apps/"$APP_NAME".png

update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

echo "✔ $APP_NAME uninstalled. Log out and back in to refresh the menu."
