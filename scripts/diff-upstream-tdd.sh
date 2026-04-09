#!/usr/bin/env bash
# diff-upstream-tdd.sh — compare forked test-driven-development skill against upstream superpowers
#
# Shows three diffs:
#   1. What changed upstream since our last recorded sync (via .last-upstream-sync)
#   2. Our fork vs current upstream (our additions — should be roughly the MUTATE/KILL content)
#   3. Suggested cherry-pick candidates (lines in upstream that changed since last sync)
#
# Run manually when a new superpowers release is noticed, or every 4-6 weeks as cadence discipline.

set -euo pipefail

UPSTREAM_REPO="obra/superpowers"
UPSTREAM_PATH="skills/test-driven-development/SKILL.md"
LOCAL="skills/test-driven-development/SKILL.md"
LAST_SYNC_REF_FILE="skills/test-driven-development/.last-upstream-sync"

if [[ ! -f "$LOCAL" ]]; then
  echo "ERROR: $LOCAL does not exist. Run from the plugin repo root." >&2
  exit 1
fi

TMP_CURRENT_UPSTREAM=$(mktemp)
TMP_PREV_UPSTREAM=$(mktemp)
trap 'rm -f "$TMP_CURRENT_UPSTREAM" "$TMP_PREV_UPSTREAM"' EXIT

echo "Fetching current upstream $UPSTREAM_PATH from $UPSTREAM_REPO (main branch)..."
curl -sSL "https://raw.githubusercontent.com/$UPSTREAM_REPO/main/$UPSTREAM_PATH" > "$TMP_CURRENT_UPSTREAM"

if [[ ! -s "$TMP_CURRENT_UPSTREAM" ]]; then
  echo "ERROR: Failed to fetch upstream file (empty response). Check network and repo URL." >&2
  exit 1
fi

echo
echo "=========================================="
echo "1. What changed upstream since last sync"
echo "=========================================="
if [[ -f "$LAST_SYNC_REF_FILE" ]]; then
  LAST_SYNC_SHA=$(cat "$LAST_SYNC_REF_FILE")
  echo "Last recorded sync: $LAST_SYNC_SHA"
  curl -sSL "https://raw.githubusercontent.com/$UPSTREAM_REPO/$LAST_SYNC_SHA/$UPSTREAM_PATH" > "$TMP_PREV_UPSTREAM" 2>/dev/null || true
  if [[ -s "$TMP_PREV_UPSTREAM" ]]; then
    if diff -q "$TMP_PREV_UPSTREAM" "$TMP_CURRENT_UPSTREAM" >/dev/null 2>&1; then
      echo "No changes upstream since last sync."
    else
      diff -u "$TMP_PREV_UPSTREAM" "$TMP_CURRENT_UPSTREAM" || true
    fi
  else
    echo "Could not fetch upstream file at last sync SHA. Upstream history may have changed."
  fi
else
  echo "No previous sync ref recorded (missing $LAST_SYNC_REF_FILE)."
fi

echo
echo "=========================================="
echo "2. Our fork vs current upstream (our additions)"
echo "=========================================="
if diff -q "$TMP_CURRENT_UPSTREAM" "$LOCAL" >/dev/null 2>&1; then
  echo "Fork is identical to upstream. No custom additions."
else
  diff -u "$TMP_CURRENT_UPSTREAM" "$LOCAL" || true
fi

echo
echo "=========================================="
echo "Next steps"
echo "=========================================="
echo "- If section 1 shows useful upstream changes, cherry-pick them into $LOCAL."
echo "- After syncing, record the new upstream SHA:"
echo "    NEW_SHA=\$(curl -sSL 'https://api.github.com/repos/$UPSTREAM_REPO/commits/main' | python3 -c 'import json,sys; print(json.load(sys.stdin)[\"sha\"])')"
echo "    echo \$NEW_SHA > $LAST_SYNC_REF_FILE"
echo "    git add $LAST_SYNC_REF_FILE $LOCAL"
echo "    git commit -m 'chore(tdd): sync with upstream superpowers (new SHA)'"
