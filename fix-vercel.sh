#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./fix-vercel.sh token   # add BLOB_READ_WRITE_TOKEN, then deploy (default)
#   ./fix-vercel.sh skip    # set VM_REQUIRED=0 for preview, then deploy

MODE="${1:-token}"

add_env() {
  local name="$1" value="$2"; shift 2
  for target in "$@"; do
    printf '%s' "$value" | vercel env add "$name" "$target" --force
  done
}

case "$MODE" in
  token)
    if [ -z "${BLOB_READ_WRITE_TOKEN:-}" ]; then
      read -rsp "Paste BLOB_READ_WRITE_TOKEN: " BLOB_READ_WRITE_TOKEN
      echo
    fi
    [ -n "$BLOB_READ_WRITE_TOKEN" ] || { echo "Token is empty"; exit 1; }
    add_env BLOB_READ_WRITE_TOKEN "$BLOB_READ_WRITE_TOKEN" preview production
    ;;
  skip)
    add_env VM_REQUIRED 0 preview
    ;;
  *)
    echo "Unknown mode: $MODE (use 'token' or 'skip')"
    exit 1
    ;;
esac

vercel
