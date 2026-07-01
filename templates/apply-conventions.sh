#!/usr/bin/env bash
# Apply the standard label taxonomy to a repo. Idempotent (gh label create --force).
#
# Usage: ./apply-conventions.sh <owner/repo> [scope]
#   scope: optional label group from labels.json — one of: web | k8s | infra
#
# Requires: gh (authenticated as the repo owner), jq.
set -euo pipefail

REPO="${1:?usage: apply-conventions.sh <owner/repo> [scope]}"
SCOPE="${2:-}"
DIR="$(cd "$(dirname "$0")" && pwd)"
LABELS="$DIR/labels.json"

apply_group() {
  local group="$1" count=0
  if [ "$(jq -r --arg g "$group" 'has($g)' "$LABELS")" != "true" ]; then
    echo "  (no '$group' group in labels.json — skipping)"; return 0
  fi
  while read -r row; do
    local name color desc
    name=$(jq -r '.name'        <<<"$row")
    color=$(jq -r '.color'       <<<"$row")
    desc=$(jq -r '.description'  <<<"$row")
    gh label create "$name" --color "$color" --description "$desc" --force -R "$REPO" >/dev/null
    echo "  ✓ $name"
    count=$((count+1))
  done < <(jq -c --arg g "$group" '.[$g][]' "$LABELS")
  echo "  ($count labels in '$group')"
}

echo "Applying base labels → $REPO"
apply_group base
if [ -n "$SCOPE" ]; then
  echo "Applying '$SCOPE' scope labels → $REPO"
  apply_group "$SCOPE"
fi
echo "Done. (Milestones, project board, and issues are repo-specific — see CONVENTIONS.md §6–7.)"
