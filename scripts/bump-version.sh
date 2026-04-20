#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "${BASH_SOURCE[0]}: line $LINENO: $BASH_COMMAND: exitcode $?"' ERR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

CURRENT=$(cargo metadata --no-deps --format-version 1 | jq -r '.packages[] | select(.name == "zola") | .version')

# Extract the webcoyote patch number and increment it
if [[ "$CURRENT" =~ ^(.+)-webcoyote\.([0-9]+)$ ]]; then
  BASE="${BASH_REMATCH[1]}"
  PATCH=$((BASH_REMATCH[2] + 1))
else
  echo "Current version ($CURRENT) doesn't match expected format X.Y.Z-webcoyote.N"
  echo "Setting to ${CURRENT}-webcoyote.1"
  BASE="$CURRENT"
  PATCH=1
fi

NEW="${BASE}-webcoyote.${PATCH}"

sed -i '' "s/^version = \"${CURRENT}\"/version = \"${NEW}\"/" Cargo.toml

echo "${CURRENT} -> ${NEW}"
