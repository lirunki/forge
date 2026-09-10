#!/data/data/com.termux/files/usr/bin/bash
# Forge Termux agent installer. Safe to run repeatedly and upgrades older installs.
set -euo pipefail
HOME="${HOME:-/data/data/com.termux/files/home}"
BIN="$HOME/bin"
SRC_DIR="/storage/emulated/0/Download/ForgeBridge"
HERE="$(cd "$(dirname "$0")" && pwd)"
AGENT_NAME="forge-termux-agent"

mkdir -p "$BIN" "$SRC_DIR/inbox" "$SRC_DIR/outbox"

SRC=""
if [[ -f "$HERE/$AGENT_NAME" ]]; then
  SRC="$HERE/$AGENT_NAME"
elif [[ -f "$SRC_DIR/$AGENT_NAME" ]]; then
  SRC="$SRC_DIR/$AGENT_NAME"
else
  echo "Missing $AGENT_NAME next to install.sh or in $SRC_DIR" >&2
  echo "Run Forge → Device bridges → Install agent again to export both files." >&2
  exit 1
fi

# Python is installed eagerly, before any daemon launch can hide its output.
if ! command -v python3 >/dev/null && ! command -v python >/dev/null; then
  if ! command -v pkg >/dev/null; then
    echo "python required but pkg not found — install it with: pkg install python" >&2
    exit 1
  fi
  echo "python not found — installing (this can take a minute)…"
  pkg install -y python || {
    pkg update -y >/dev/null 2>&1 || true
    pkg install -y python
  }
fi

# Always replace the installed agent. Removing first avoids ETXTBSY on
# Android/Termux when the previous agent is still running.
install_agent() {
  local src="$1" dst="$2"
  rm -f "$dst"
  cp -f "$src" "$dst"
  chmod +x "$dst"
}

install_agent "$SRC" "$BIN/$AGENT_NAME"
install_agent "$SRC" "$SRC_DIR/$AGENT_NAME"
if [[ -f "$HERE/install.sh" ]]; then
  install_agent "$HERE/install.sh" "$SRC_DIR/install.sh"
fi
changed=1

BASHRC="$HOME/.bashrc"
if [[ ! -f "$BASHRC" ]]; then
  : > "$BASHRC"
fi
PATH_LINE='export PATH="$HOME/bin:$PATH"'
if ! grep -Fqx "$PATH_LINE" "$BASHRC" 2>/dev/null; then
  printf '\n%s\n' "$PATH_LINE" >> "$BASHRC"
  changed=1
fi

# Guarded auto-start: opening another Termux shell is a no-op when the same
# version is already alive. The agent itself owns PID/version de-duplication.
AUTO_START_MARK='# Forge Termux agent auto-start'
if ! grep -Fqx "$AUTO_START_MARK" "$BASHRC" 2>/dev/null; then
  cat >> "$BASHRC" <<'EOF'

# Forge Termux agent auto-start
if [ -x "$HOME/bin/forge-termux-agent" ]; then
  "$HOME/bin/forge-termux-agent" --daemon >/dev/null 2>&1 &
fi
EOF
  changed=1
fi
export PATH="$BIN:$PATH"

if [[ "$changed" -eq 0 ]]; then
  echo "Already installed — no changes needed."
else
  echo "Installed/updated: $BIN/$AGENT_NAME"
fi
echo "Auto-start: guarded .bashrc launch (same-version agent is left running)"
echo "Start manually: $BIN/$AGENT_NAME"
