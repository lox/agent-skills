#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/../scripts/pr_babysit.sh"

required_pass='[{"bucket":"pass","link":"https://ci.example/1","name":"build","state":"SUCCESS","workflow":"CI"}]'
required_pending='[{"bucket":"pending","link":"https://ci.example/1","name":"build","state":"PENDING","workflow":"CI"}]'
advisory_pending='{"bucket":"pending","link":"https://review.example/1","name":"advisory review","state":"PENDING","workflow":"Review"}'
advisory_failure='{"bucket":"fail","link":"https://review.example/1","name":"advisory review","state":"FAILURE","workflow":"Review"}'

pr_meta='{
  "state":"OPEN",
  "isDraft":false,
  "mergeable":"MERGEABLE",
  "mergeStateStatus":"CLEAN",
  "reviewDecision":""
}'
threads='{"unresolved_review_threads_count":0,"unresolved_review_threads":[]}'
codex='{
  "pending_review":false,
  "actionable_diff_comments_count":0,
  "actionable_top_level_reviews_count":0,
  "codex_review_required":false,
  "main_thread_approved":true
}'

all_checks="$(jq -cn --argjson required "$required_pass" --argjson advisory "$advisory_pending" '$required + [$advisory]')"
checks="$(checks_summary_json "$all_checks" "$required_pass")"
jq -e '
  .any_pending == false
  and .required.any_pending == false
  and .advisory.any_pending == true
  and (.advisory.checks | length) == 1
' >/dev/null <<<"$checks"

status="$(status_summary_json "$pr_meta" "$checks" "$threads" "$codex")"
jq -e '.ready_to_merge == true and (.merge_blockers | length) == 0' >/dev/null <<<"$status"

all_checks="$(jq -cn --argjson required "$required_pending" --argjson advisory "$advisory_pending" '$required + [$advisory]')"
checks="$(checks_summary_json "$all_checks" "$required_pending")"
status="$(status_summary_json "$pr_meta" "$checks" "$threads" "$codex")"
jq -e '
  .ready_to_merge == false
  and .checks.required.any_pending == true
  and (.merge_blockers | index("pending_checks")) != null
' >/dev/null <<<"$status"

all_checks="$(jq -cn --argjson required "$required_pass" --argjson advisory "$advisory_failure" '$required + [$advisory]')"
checks="$(checks_summary_json "$all_checks" "$required_pass")"
status="$(status_summary_json "$pr_meta" "$checks" "$threads" "$codex")"
jq -e '
  .ready_to_merge == true
  and .checks.any_failed == false
  and .checks.advisory.any_failed == true
  and (.merge_blockers | length) == 0
' >/dev/null <<<"$status"

echo "pr_babysit tests passed"
