#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  pr_babysit.sh status      [--pr <number>] [--repo <owner/repo>] [--codex-pattern <regex>]
  pr_babysit.sh codex-state [--pr <number>] [--repo <owner/repo>] [--codex-pattern <regex>]
  pr_babysit.sh codex-wait  [--pr <number>] [--repo <owner/repo>] [--timeout <seconds>] [--interval <seconds>] [--codex-pattern <regex>]
  pr_babysit.sh resolve     [--pr <number>] [--repo <owner/repo>] --comment-ids <id1,id2,...>
  pr_babysit.sh checks      [--pr <number>] [--repo <owner/repo>]

Commands:
  status       Print JSON summary of PR merge readiness, checks, review threads, and Codex state.
  codex-state  Print JSON summary of Codex review status for the PR.
  codex-wait   Poll until pending Codex review completes or timeout occurs.
  resolve      Resolve review threads containing the given diff comment IDs.
  checks       Show CI check status for the PR as JSON.

Aliases:
  state        Alias for status.
  wait         Alias for codex-wait.
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required command: $1" >&2
    exit 1
  fi
}

require_bk_auth() {
  if ! bk auth status >/dev/null 2>&1; then
    echo "bk auth is not logged in; run: bk auth login" >&2
    exit 42
  fi
}

now_epoch() {
  date +%s
}

resolve_repo() {
  local repo="$1"
  if [[ -n "$repo" ]]; then
    echo "$repo"
    return
  fi
  gh repo view --json nameWithOwner --jq .nameWithOwner
}

resolve_pr() {
  local pr="$1"
  if [[ -n "$pr" ]]; then
    echo "$pr"
    return
  fi
  gh pr view --json number --jq .number
}

paginated_array() {
  gh api "$1" --paginate --slurp | jq 'add'
}

review_threads_graphql_json() {
  local repo="$1"
  local pr="$2"

  local owner name
  owner="${repo%%/*}"
  name="${repo##*/}"

  local all_threads='[]'
  local cursor=""

  while :; do
    local response page_threads has_next
    local api_args=(-f owner="$owner" -f name="$name" -F pr="$pr")
    if [[ -n "$cursor" ]]; then
      api_args+=(-f after="$cursor")
    fi

    response="$(gh api graphql "${api_args[@]}" -f query='
      query($owner: String!, $name: String!, $pr: Int!, $after: String) {
        repository(owner: $owner, name: $name) {
          pullRequest(number: $pr) {
            reviewThreads(first: 100, after: $after) {
              nodes {
                id
                isResolved
                comments(first: 1) {
                  nodes {
                    databaseId
                    body
                    author { login }
                  }
                }
              }
              pageInfo {
                hasNextPage
                endCursor
              }
            }
          }
        }
      }
    ')"

    page_threads="$(jq '.data.repository.pullRequest.reviewThreads.nodes' <<<"$response")"
    all_threads="$(jq -cn --argjson all "$all_threads" --argjson page "$page_threads" '$all + $page')"

    has_next="$(jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage' <<<"$response")"
    if [[ "$has_next" != "true" ]]; then
      break
    fi

    cursor="$(jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor // empty' <<<"$response")"
    if [[ -z "$cursor" ]]; then
      echo "GitHub reported another review-thread page without an end cursor" >&2
      exit 1
    fi
  done

  echo "$all_threads"
}

resolve_threads() {
  local repo="$1"
  local pr="$2"
  local comment_ids="$3"

  local threads
  threads="$(review_threads_graphql_json "$repo" "$pr")"

  local ids_json
  ids_json="$(echo "$comment_ids" | tr ',' '\n' | jq -Rn '[inputs | select(. != "") | tonumber]')"

  local thread_ids
  thread_ids="$(jq -r \
    --argjson ids "$ids_json" '
      .[]
      | select(.isResolved | not)
      | select(.comments.nodes[0].databaseId as $cid | $ids | index($cid))
      | .id
    ' <<<"$threads")"

  local resolved=0
  for tid in $thread_ids; do
    gh api graphql -f query='
      mutation($threadId: ID!) {
        resolveReviewThread(input: {threadId: $threadId}) {
          thread { id isResolved }
        }
      }
    ' -f threadId="$tid" >/dev/null
    resolved=$((resolved + 1))
  done

  jq -cn --argjson resolved "$resolved" '{resolved_count: $resolved}'
}

checks_json() {
  local repo="$1"
  local pr="$2"

  local checks
  local checks_output
  local checks_exit
  set +e
  checks_output="$(gh pr checks "$pr" --repo "$repo" --json name,state,bucket,link,workflow 2>&1)"
  checks_exit=$?
  set -e
  if [[ $checks_exit -eq 0 || $checks_exit -eq 8 ]]; then
    checks="$checks_output"
  elif [[ "$checks_output" == no\ checks\ reported* ]]; then
    checks='[]'
  else
    echo "$checks_output" >&2
    exit "$checks_exit"
  fi
  if [[ -z "$checks" ]]; then
    checks='[]'
  fi

  local all_passed
  all_passed="$(jq '[.[] | .bucket == "pass" or .bucket == "skipping"] | all' <<<"$checks")"

  local any_failed
  any_failed="$(jq '[.[] | .bucket == "fail" or .bucket == "cancel"] | any' <<<"$checks")"

  local any_pending
  any_pending="$(jq '[.[] | .bucket == "pending"] | any' <<<"$checks")"

  jq -cn \
    --argjson checks "$checks" \
    --argjson all_passed "$all_passed" \
    --argjson any_failed "$any_failed" \
    --argjson any_pending "$any_pending" '
      {
        all_passed: $all_passed,
        any_failed: $any_failed,
        any_pending: $any_pending,
        checks: $checks
      }
    '
}

review_threads_json() {
  local repo="$1"
  local pr="$2"

  local nodes
  nodes="$(review_threads_graphql_json "$repo" "$pr")"

  jq -cn --argjson threads "$nodes" '
    {
      unresolved_review_threads_count: ([ $threads[] | select(.isResolved | not) ] | length),
      unresolved_review_threads: [
        $threads[]
        | select(.isResolved | not)
        | {
            id,
            first_comment_id: (.comments.nodes[0].databaseId // null),
            user: (.comments.nodes[0].author.login // null),
            body: ((.comments.nodes[0].body // "") | .[0:300])
          }
      ]
    }
  '
}

codex_helper_path() {
  local script_dir
  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

  local candidates=(
    "${script_dir}/../../handling-codex-reviews/scripts/codex_review_loop.sh"
    "${HOME}/.config/agents/skills/handling-codex-reviews/scripts/codex_review_loop.sh"
  )

  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -x "$candidate" ]]; then
      echo "$candidate"
      return
    fi
  done

  echo "missing handling-codex-reviews helper; install or load that skill" >&2
  exit 1
}

codex_json() {
  local repo="$1"
  local pr="$2"
  local codex_pattern="$3"
  "$(codex_helper_path)" state --repo "$repo" --pr "$pr" --codex-pattern "$codex_pattern"
}
status_json() {
  local repo="$1"
  local pr="$2"
  local codex_pattern="$3"

  local pr_meta checks threads codex
  pr_meta="$(gh pr view "$pr" --repo "$repo" --json number,url,title,state,isDraft,headRefName,baseRefName,headRefOid,mergeable,mergeStateStatus,reviewDecision,reviewRequests,latestReviews,author)"
  checks="$(checks_json "$repo" "$pr")"
  threads="$(review_threads_json "$repo" "$pr")"
  codex="$(codex_json "$repo" "$pr" "$codex_pattern")"

  jq -cn \
    --argjson pr "$pr_meta" \
    --argjson checks "$checks" \
    --argjson threads "$threads" \
    --argjson codex "$codex" '
      [
        if $pr.state != "OPEN" then "pr_not_open" else empty end,
        if $pr.isDraft == true then "draft" else empty end,
        if ($pr.mergeable // "") == "CONFLICTING" then "merge_conflicts" else empty end,
        if ($pr.mergeable // "") == "UNKNOWN" then "mergeability_unknown" else empty end,
        if ($pr.mergeStateStatus // "") == "BEHIND" then "branch_behind_base" else empty end,
        if ($pr.mergeStateStatus // "") == "BLOCKED" then "merge_blocked" else empty end,
        if ($pr.mergeStateStatus // "") == "DIRTY" then "merge_conflicts" else empty end,
        if ($pr.mergeStateStatus // "") == "UNKNOWN" then "merge_state_unknown" else empty end,
        if ($pr.reviewDecision // "") == "CHANGES_REQUESTED" then "changes_requested" else empty end,
        if ($pr.reviewDecision // "") == "REVIEW_REQUIRED" then "review_required" else empty end,
        if $threads.unresolved_review_threads_count > 0 then "unresolved_review_threads" else empty end,
        if $codex.pending_review == true then "pending_codex_review" else empty end,
        if $codex.actionable_diff_comments_count > 0 then "actionable_codex_comments" else empty end,
        if $codex.actionable_top_level_reviews_count > 0 then "actionable_codex_top_level_reviews" else empty end,
        if (($codex.pending_review | not) and $codex.codex_review_required == true and $codex.main_thread_approved == false) then "codex_thumbs_up_missing" else empty end,
        if $checks.any_failed == true then "failed_checks" else empty end,
        if $checks.any_pending == true then "pending_checks" else empty end
      ] as $blockers
      | {
          bk_auth: true,
          pr: $pr,
          checks: $checks,
          review_threads: $threads,
          codex: $codex,
          merge_blockers: $blockers,
          ready_to_merge: (($blockers | length) == 0)
        }
    '
}

main() {
  if [[ $# -lt 1 ]]; then
    usage
    exit 1
  fi

  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
    exit 0
  fi

  local mode="$1"
  shift

  local pr=""
  local repo=""
  local codex_pattern='codex|chatgpt-codex-connector'
  local timeout=900
  local interval=20
  local comment_ids=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --pr)
        pr="$2"
        shift 2
        ;;
      --repo)
        repo="$2"
        shift 2
        ;;
      --codex-pattern)
        codex_pattern="$2"
        shift 2
        ;;
      --timeout)
        timeout="$2"
        shift 2
        ;;
      --interval)
        interval="$2"
        shift 2
        ;;
      --comment-ids)
        comment_ids="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "unknown argument: $1" >&2
        usage
        exit 1
        ;;
    esac
  done

  require_cmd gh
  require_cmd jq
  require_cmd bk
  require_bk_auth

  repo="$(resolve_repo "$repo")"
  pr="$(resolve_pr "$pr")"

  case "$mode" in
    status|state)
      status_json "$repo" "$pr" "$codex_pattern"
      ;;
    codex-state)
      codex_json "$repo" "$pr" "$codex_pattern"
      ;;
    resolve)
      if [[ -z "$comment_ids" ]]; then
        echo "resolve requires --comment-ids" >&2
        exit 1
      fi
      resolve_threads "$repo" "$pr" "$comment_ids"
      ;;
    checks)
      checks_json "$repo" "$pr"
      ;;
    codex-wait|wait)
      local start end now state pending
      start="$(now_epoch)"
      end=$((start + timeout))

      while :; do
        state="$(codex_json "$repo" "$pr" "$codex_pattern")"
        pending="$(jq -r '.pending_review' <<<"$state")"
        if [[ "$pending" == "false" ]]; then
          echo "$state"
          exit 0
        fi

        now="$(now_epoch)"
        if (( now >= end )); then
          echo "$state"
          echo "wait timed out after ${timeout}s" >&2
          exit 2
        fi

        sleep "$interval"
      done
      ;;
    *)
      echo "unknown mode: $mode" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
