#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
VERSION=1.0.3
OUTPUT="${1:-${TMPDIR:-/tmp}/forgechat-linux-agent-${VERSION}.tar.gz}"
OUTPUT_DIR="$(dirname -- "$OUTPUT")"
mkdir -p -- "$OUTPUT_DIR"
STAGE="$(mktemp -d)"
trap 'rm -rf -- "$STAGE"' EXIT

mkdir -p "$STAGE/server/deploy/linux-agent" "$STAGE/server/forgechat"
for file in README.md Dockerfile docker-compose.yml pkg setup.sh; do
  cp -- "$SCRIPT_DIR/$file" "$STAGE/server/deploy/linux-agent/$file"
done
cp -- "$SERVER_DIR/forgechat/linux_agent.py" "$STAGE/server/forgechat/linux_agent.py"
tar -czf "$OUTPUT" -C "$STAGE" server
chmod 0644 "$OUTPUT"
printf 'Created private-agent deployment package: %s\n' "$OUTPUT"
