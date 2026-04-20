#!/usr/bin/env bash
set -euo pipefail

REPO="webcoyote/zola"
RULESET_NAME="Require PR checks"

BODY='
{
  "name": "Require PR checks",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/heads/master"],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 0,
        "dismiss_stale_reviews_on_push": false,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": false,
        "required_status_checks": [
          {
            "context": "Tests",
            "integration_id": 15368
          }
        ]
      }
    }
  ],
  "bypass_actors": []
}
'

# Check if ruleset already exists
RULESET_ID=$(gh api "repos/${REPO}/rulesets" --jq ".[] | select(.name == \"${RULESET_NAME}\") | .id" 2>/dev/null || true)

if [[ -n "$RULESET_ID" ]]; then
  echo "Updating existing ruleset (id: ${RULESET_ID})..."
  echo "$BODY" | gh api "repos/${REPO}/rulesets/${RULESET_ID}" -X PUT -H "Accept: application/vnd.github+json" --input -
else
  echo "Creating new ruleset..."
  echo "$BODY" | gh api "repos/${REPO}/rulesets" -X POST -H "Accept: application/vnd.github+json" --input -
fi

echo "Done: branch protection ruleset for ${REPO}"
