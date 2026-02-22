#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  codex_review_loop.sh state   [--pr <number>] [--repo <owner/repo>] [--codex-pattern <regex>]
  codex_review_loop.sh wait    [--pr <number>] [--repo <owner/repo>] [--timeout <seconds>] [--interval <seconds>] [--codex-pattern <regex>]
  codex_review_loop.sh resolve [--pr <number>] [--repo <owner/repo>] --comment-ids <id1,id2,...>
  codex_review_loop.sh checks  [--pr <number>] [--repo <owner/repo>]

Commands:
  state    Print JSON summary of Codex review status for the PR.
  wait     Poll until pending Codex review completes or timeout occurs.
  resolve  Resolve review threads containing the given comment IDs.
  checks   Show CI check status for the PR as JSON.
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required command: $1" >&2
    exit 1
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

resolve_threads() {
  local repo="$1"
  local pr="$2"
  local comment_ids="$3"

  local owner name
  owner="${repo%%/*}"
  name="${repo##*/}"

  # Fetch all review threads with their first comment's databaseId
  local threads
  threads="$(gh api graphql -f query='
    query($owner: String!, $name: String!, $pr: Int!) {
      repository(owner: $owner, name: $name) {
        pullRequest(number: $pr) {
          reviewThreads(first: 100) {
            nodes {
              id
              isResolved
              comments(first: 1) {
                nodes {
                  databaseId
                }
              }
            }
          }
        }
      }
    }
  ' -f owner="$owner" -f name="$name" -F pr="$pr")"

  # Build array of target comment IDs
  local ids_json
  ids_json="$(echo "$comment_ids" | tr ',' '\n' | jq -Rn '[inputs | select(. != "") | tonumber]')"

  # Find threads whose first comment matches any target ID and resolve them
  local thread_ids
  thread_ids="$(jq -r \
    --argjson ids "$ids_json" '
      .data.repository.pullRequest.reviewThreads.nodes[]
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
  checks="$(gh pr checks "$pr" --repo "$repo" --json name,state,conclusion,detailsUrl 2>/dev/null || echo '[]')"

  local all_passed
  all_passed="$(jq '[.[] | .conclusion == "SUCCESS" or .conclusion == "NEUTRAL" or .conclusion == "SKIPPED"] | all' <<<"$checks")"

  local any_failed
  any_failed="$(jq '[.[] | .conclusion == "FAILURE" or .conclusion == "CANCELLED" or .conclusion == "TIMED_OUT" or .conclusion == "ACTION_REQUIRED"] | any' <<<"$checks")"

  local any_pending
  any_pending="$(jq '[.[] | .state == "QUEUED" or .state == "IN_PROGRESS" or .state == "WAITING" or .state == "PENDING"] | any' <<<"$checks")"

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

state_json() {
  local repo="$1"
  local pr="$2"
  local codex_pattern="$3"

  local issue_comments reviews diff_comments
  issue_comments="$(gh api "repos/$repo/issues/$pr/comments" --paginate)"
  reviews="$(gh api "repos/$repo/pulls/$pr/reviews" --paginate)"
  diff_comments="$(gh api "repos/$repo/pulls/$pr/comments" --paginate)"

  local latest_trigger latest_trigger_time latest_trigger_id latest_trigger_user
  latest_trigger="$(jq -c '
    map(select(.body | test("(?m)^@codex\\s+review\\b")))
    | sort_by(.created_at)
    | last // empty
  ' <<<"$issue_comments")"

  latest_trigger_time=""
  latest_trigger_id=""
  latest_trigger_user=""
  if [[ -n "$latest_trigger" ]]; then
    latest_trigger_time="$(jq -r '.created_at' <<<"$latest_trigger")"
    latest_trigger_id="$(jq -r '.id' <<<"$latest_trigger")"
    latest_trigger_user="$(jq -r '.user.login' <<<"$latest_trigger")"
  fi

  local codex_events latest_codex_event_time
  codex_events="$(jq -cn \
    --argjson reviews "$reviews" \
    --argjson issue_comments "$issue_comments" \
    --argjson diff_comments "$diff_comments" \
    --arg pattern "$codex_pattern" '
      [
        ($reviews[] | select(.user.login | test($pattern; "i")) | {kind:"review", id, created_at, user: .user.login, state}),
        ($issue_comments[] | select(.user.login | test($pattern; "i")) | {kind:"issue_comment", id, created_at, user: .user.login}),
        ($diff_comments[] | select(.user.login | test($pattern; "i")) | {kind:"diff_comment", id, created_at, user: .user.login, path, line})
      ]
      | sort_by(.created_at)
    ')"
  latest_codex_event_time="$(jq -r 'last.created_at // empty' <<<"$codex_events")"

  local pending_review="false"
  if [[ -n "$latest_trigger_time" ]]; then
    if [[ -z "$latest_codex_event_time" ]] || [[ "$latest_codex_event_time" < "$latest_trigger_time" ]]; then
      pending_review="true"
    fi
  fi

  local trigger_reactions='[]'
  if [[ -n "$latest_trigger_id" ]]; then
    trigger_reactions="$(gh api "repos/$repo/issues/comments/$latest_trigger_id/reactions" --paginate 2>/dev/null || echo '[]')"
  fi

  local actionable_diff_roots actionable_diff_count
  actionable_diff_roots="$(jq -cn \
    --argjson comments "$diff_comments" \
    --arg pattern "$codex_pattern" '
      $comments as $all
      | [
          $all[]
          | select((.in_reply_to_id == null) and (.user.login | test($pattern; "i")))
          | . as $root
          | {
              id: $root.id,
              created_at: $root.created_at,
              user: $root.user.login,
              path: $root.path,
              line: ($root.line // $root.original_line),
              body: $root.body,
              has_non_codex_reply: (
                [
                  $all[]
                  | select(.in_reply_to_id == $root.id)
                  | select((.user.login | test($pattern; "i")) | not)
                ]
                | length > 0
              )
            }
          | select(.has_non_codex_reply | not)
        ]
    ')"
  actionable_diff_count="$(jq 'length' <<<"$actionable_diff_roots")"

  local open_review_bodies
  open_review_bodies="$(jq -cn \
    --argjson reviews "$reviews" \
    --arg pattern "$codex_pattern" '
      [
        $reviews[]
        | select(.user.login | test($pattern; "i"))
        | select((.state // "") | ascii_downcase == "commented")
        | select((.body // "") != "")
        | {id, created_at, user: .user.login, body}
      ]
    ')"

  jq -cn \
    --arg repo "$repo" \
    --argjson pr "$pr" \
    --arg codex_pattern "$codex_pattern" \
    --arg latest_trigger_time "$latest_trigger_time" \
    --arg latest_trigger_user "$latest_trigger_user" \
    --arg latest_codex_event_time "$latest_codex_event_time" \
    --argjson pending_review "$pending_review" \
    --argjson trigger_reactions "$trigger_reactions" \
    --argjson codex_events "$codex_events" \
    --argjson actionable_diff_comments "$actionable_diff_roots" \
    --argjson actionable_diff_comments_count "$actionable_diff_count" \
    --argjson codex_top_level_reviews "$open_review_bodies" '
      {
        repo: $repo,
        pr: $pr,
        codex_pattern: $codex_pattern,
        latest_trigger: {
          created_at: (if $latest_trigger_time == "" then null else $latest_trigger_time end),
          user: (if $latest_trigger_user == "" then null else $latest_trigger_user end),
          reactions_count: ($trigger_reactions | length)
        },
        latest_codex_activity_at: (if $latest_codex_event_time == "" then null else $latest_codex_event_time end),
        pending_review: $pending_review,
        actionable_diff_comments_count: $actionable_diff_comments_count,
        actionable_diff_comments: $actionable_diff_comments,
        codex_top_level_reviews: $codex_top_level_reviews,
        ready_for_merge: ((($pending_review | not) and ($actionable_diff_comments_count == 0)))
      }
    '
}

main() {
  require_cmd gh
  require_cmd jq

  if [[ $# -lt 1 ]]; then
    usage
    exit 1
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

  repo="$(resolve_repo "$repo")"
  pr="$(resolve_pr "$pr")"

  case "$mode" in
    state)
      state_json "$repo" "$pr" "$codex_pattern"
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
    wait)
      local start end now state pending
      start="$(now_epoch)"
      end=$((start + timeout))

      while :; do
        state="$(state_json "$repo" "$pr" "$codex_pattern")"
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
