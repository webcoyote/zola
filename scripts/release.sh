#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "${BASH_SOURCE[0]}: line $LINENO: $BASH_COMMAND: exitcode $?"' ERR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

VERSION=$(cargo metadata --no-deps --format-version 1 | jq -r '.packages[] | select(.name == "zola") | .version')
TAG="v${VERSION}"

echo "Tagging ${TAG} and pushing..."
git tag "$TAG"
git push origin "$TAG"

echo "Done. Release will be built at:"
echo "  https://github.com/webcoyote/zola/actions"
