#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
HOME="${HOME:-/data/data/com.termux/files/home}"
BIN="$HOME/bin"
SRC_DIR="/storage/emulated/0/Download/ForgeBridge"
HERE="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$BIN" "$SRC_DIR/inbox" "$SRC_DIR/outbox"

SRC=""
if [[ -f "$HERE/forge-termux-agent" ]]; then
  SRC="$HERE/forge-termux-agent"
elif [[ -f "$SRC_DIR/forge-termux-agent" ]]; then
  SRC="$SRC_DIR/forge-termux-agent"
else
  echo "Missing forge-termux-agent next to install.sh or in $SRC_DIR" >&2
  exit 1
fi

cp -f "$SRC" "$BIN/forge-termux-agent"
cp -f "$SRC" "$SRC_DIR/forge-termux-agent"
chmod +x "$BIN/forge-termux-agent" "$SRC_DIR/forge-termux-agent"

if [[ -f "$HERE/install.sh" ]]; then
  cp -f "$HERE/install.sh" "$SRC_DIR/install.sh"
  chmod +x "$SRC_DIR/install.sh"
fi

if [[ -f "$HOME/.bashrc" ]] && ! grep -q 'HOME/bin' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
fi
export PATH="$BIN:$PATH"

if ! command -v python3 >/dev/null && ! command -v python >/dev/null; then
  echo "Installing python..."
  pkg install -y python
fi

echo "Installed: $BIN/forge-termux-agent"
echo "Start:     forge-termux-agent"
echo "Daemonize: forge-termux-agent --daemon"
