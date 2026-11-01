#!/usr/bin/env bash
set -euo pipefail
umask 077

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  printf 'Run this one-time installer with sudo: sudo %s\n' "$0" >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR=/opt/forgechat/linux-agent
ENV_DIR=/etc/forgechat
ENV_FILE="$ENV_DIR/linux-agent.env"
DROPIN_DIR=/etc/systemd/system/forgechat.service.d
DROPIN="$DROPIN_DIR/40-linux-agent.conf"
DATA_DIR=/var/lib/forgechat/linux-agent/workspace

for command in docker openssl curl systemctl install python3; do
  command -v "$command" >/dev/null 2>&1 || { printf 'Required command is unavailable: %s\n' "$command" >&2; exit 1; }
done
docker compose version >/dev/null 2>&1 || { printf 'Docker Compose v2 is required.\n' >&2; exit 1; }
systemctl cat forgechat.service >/dev/null 2>&1 || { printf 'forgechat.service must be installed before provisioning the agent.\n' >&2; exit 1; }
getent group forgechat >/dev/null || { printf 'The forgechat service group does not exist.\n' >&2; exit 1; }

install -d -o root -g root -m 0755 "$INSTALL_DIR"
install -o root -g root -m 0644 "$SCRIPT_DIR/Dockerfile" "$INSTALL_DIR/Dockerfile"
install -o root -g root -m 0644 "$SCRIPT_DIR/docker-compose.yml" "$INSTALL_DIR/docker-compose.yml"
install -o root -g root -m 0755 "$SCRIPT_DIR/pkg" "$INSTALL_DIR/pkg"
install -o root -g root -m 0644 "$SCRIPT_DIR/../../forgechat/linux_agent.py" "$INSTALL_DIR/linux_agent.py"
install -d -o root -g forgechat -m 0750 "$ENV_DIR"
install -d -o root -g root -m 0755 "$DROPIN_DIR"
install -d -o 10000 -g 10000 -m 0700 "$DATA_DIR" "$DATA_DIR/fs" "$DATA_DIR/home"

if [[ -L "$ENV_FILE" ]]; then
  printf 'Refusing to use a symlink as the agent credential file.\n' >&2
  exit 1
fi
if [[ ! -e "$ENV_FILE" ]]; then
  agent_username="forge_$(openssl rand -hex 10)"
  agent_password="$(openssl rand -hex 32)"
  temp_env="$(mktemp "$ENV_DIR/.linux-agent.env.XXXXXX")"
  trap 'rm -f -- "${temp_env:-}"' EXIT
  printf 'FORGECHAT_AGENT_USERNAME=%s\nFORGECHAT_AGENT_PASSWORD=%s\nFORGECHAT_AGENT_URL=http://127.0.0.1:8788\n' \
    "$agent_username" "$agent_password" > "$temp_env"
  chown root:forgechat "$temp_env"
  chmod 0640 "$temp_env"
  mv -f -- "$temp_env" "$ENV_FILE"
  trap - EXIT
else
  [[ -f "$ENV_FILE" ]] || { printf 'Agent credential path exists but is not a regular file.\n' >&2; exit 1; }
  python3 - "$ENV_FILE" <<'PY'
import re
import sys
from pathlib import Path

entries = {}
for line in Path(sys.argv[1]).read_text(encoding="utf-8").splitlines():
    if not line or line.lstrip().startswith("#"):
        continue
    key, sep, value = line.partition("=")
    if not sep or key in entries:
        raise SystemExit("Invalid private agent configuration; refusing to rotate credentials.")
    entries[key] = value
if not re.fullmatch(r"forge_[0-9a-f]{20}", entries.get("FORGECHAT_AGENT_USERNAME", "")):
    raise SystemExit("Invalid private agent username; refusing to rotate credentials.")
if not re.fullmatch(r"[0-9a-f]{64}", entries.get("FORGECHAT_AGENT_PASSWORD", "")):
    raise SystemExit("Invalid private agent password; refusing to rotate credentials.")
if set(entries) != {"FORGECHAT_AGENT_USERNAME", "FORGECHAT_AGENT_PASSWORD", "FORGECHAT_AGENT_URL"}:
    raise SystemExit("Unexpected private agent settings; refusing to change them automatically.")
if entries.get("FORGECHAT_AGENT_URL") != "http://127.0.0.1:8788":
    raise SystemExit("Unexpected private agent URL; refusing to change it automatically.")
PY
  chown root:forgechat "$ENV_FILE"
  chmod 0640 "$ENV_FILE"
fi

if [[ -e "$DROPIN" && -L "$DROPIN" ]]; then
  printf 'Refusing to replace a symlink at the ForgeChat systemd drop-in path.\n' >&2
  exit 1
fi
if [[ -e "$DROPIN" ]] && ! grep -Fxq "EnvironmentFile=-$ENV_FILE" "$DROPIN"; then
  printf 'Unexpected existing ForgeChat Linux-agent drop-in; refusing to overwrite it.\n' >&2
  exit 1
fi
temp_dropin="$(mktemp "$DROPIN_DIR/.40-linux-agent.conf.XXXXXX")"
trap 'rm -f -- "${temp_dropin:-}"' EXIT
printf '[Service]\nEnvironmentFile=-%s\n' "$ENV_FILE" > "$temp_dropin"
chown root:root "$temp_dropin"
chmod 0644 "$temp_dropin"
mv -f -- "$temp_dropin" "$DROPIN"
trap - EXIT

cd "$INSTALL_DIR"
docker compose --env-file "$ENV_FILE" -f docker-compose.yml up -d --build

# Authenticate through curl's private stdin config; credentials never appear in
# command arguments, terminal output, container logs, or this script's output.
agent_username="$(python3 - "$ENV_FILE" <<'PY'
import sys
from pathlib import Path
for line in Path(sys.argv[1]).read_text(encoding="utf-8").splitlines():
    if line.startswith("FORGECHAT_AGENT_USERNAME="):
        print(line.partition("=")[2])
        break
PY
)"
agent_password="$(python3 - "$ENV_FILE" <<'PY'
import sys
from pathlib import Path
for line in Path(sys.argv[1]).read_text(encoding="utf-8").splitlines():
    if line.startswith("FORGECHAT_AGENT_PASSWORD="):
        print(line.partition("=")[2])
        break
PY
)"
ready=false
for _ in $(seq 1 30); do
  if printf 'user = "%s:%s"\n' "$agent_username" "$agent_password" \
      | curl --config - --fail --silent --show-error --connect-timeout 1 --max-time 3 \
          http://127.0.0.1:8788/status >/dev/null 2>&1; then
    ready=true
    break
  fi
  sleep 1
done
unset agent_username agent_password
if [[ "$ready" != true ]]; then
  printf 'Linux agent did not become healthy. Check Docker service status without printing environment values.\n' >&2
  exit 1
fi

systemctl daemon-reload
systemctl restart forgechat.service
if ! systemctl is-active --quiet forgechat.service; then
  printf 'ForgeChat did not become active after the private agent configuration was added.\n' >&2
  exit 1
fi

printf 'Private ForgeChat Linux agent provisioned on loopback. Generated credentials are stored in %s and were not displayed.\n' "$ENV_FILE"
printf 'Agent commands are disabled for app users until the owner grants access in %s/users.\n' "${FORGECHAT_PUBLIC_URL:-/forgechat}"
