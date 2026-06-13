#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF_USAGE'
Usage:
  codex_review_loop.sh state   [--pr <number>] [--repo <owner/repo>] [--codex-pattern <regex>]
  codex_review_loop.sh wait    [--pr <number>] [--repo <owner/repo>] [--timeout <seconds>] [--interval <seconds>] [--codex-pattern <regex>]
  codex_review_loop.sh resolve [--pr <number>] [--repo <owner/repo>] --comment-ids <id1,id2,...>
  codex_review_loop.sh checks  [--pr <number>] [--repo <owner/repo>]

Commands:
  state    Print JSON summary of Codex review status for the PR.
  wait     Poll until pending Codex review completes or timeout occurs.
  resolve  Resolve review threads containing the given diff comment IDs.
  checks   Show CI check status for the PR as JSON.
EOF_USAGE
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
  if jq -e type >/dev/null 2>&1 <<<"$checks_output"; then
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

state_json() {
  local repo="$1"
  local pr="$2"
  local codex_pattern="$3"

  local issue_comments reviews diff_comments
  issue_comments="$(paginated_array "repos/$repo/issues/$pr/comments")"
  reviews="$(paginated_array "repos/$repo/pulls/$pr/reviews")"
  diff_comments="$(paginated_array "repos/$repo/pulls/$pr/comments")"

  local head_oid head_committed_at
  head_oid="$(gh pr view "$pr" --repo "$repo" --json headRefOid --jq .headRefOid)"
  head_committed_at="$(gh api "repos/$repo/commits/$head_oid" --jq '.commit.committer.date')"

  local latest_trigger latest_trigger_time latest_trigger_id latest_trigger_user latest_trigger_head_oid
  latest_trigger="$(jq -c '
    map(select(.body | test("(?m)^@codex\\s+review\\b")))
    | sort_by(.created_at)
    | last // empty
  ' <<<"$issue_comments")"

  latest_trigger_time=""
  latest_trigger_id=""
  latest_trigger_user=""
  latest_trigger_head_oid=""
  if [[ -n "$latest_trigger" ]]; then
    latest_trigger_time="$(jq -r '.created_at' <<<"$latest_trigger")"
    latest_trigger_id="$(jq -r '.id' <<<"$latest_trigger")"
    latest_trigger_user="$(jq -r '.user.login' <<<"$latest_trigger")"
    latest_trigger_head_oid="$(jq -r '(.body | capture("(?im)^Head:[[:space:]]*(?<sha>[0-9a-f]{40})")? // {}).sha // ""' <<<"$latest_trigger")"
  fi

  local codex_events latest_codex_event_time
  codex_events="$(jq -cn \
    --argjson reviews "$reviews" \
    --argjson issue_comments "$issue_comments" \
    --argjson diff_comments "$diff_comments" \
    --arg pattern "$codex_pattern" '
      [
        ($reviews[] | select(.user.login | test($pattern; "i")) | {kind:"review", id, created_at: (.submitted_at // .created_at), user: .user.login, state}),
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
    trigger_reactions="$(gh api "repos/$repo/issues/comments/$latest_trigger_id/reactions" --paginate --slurp 2>/dev/null | jq 'add' || echo '[]')"
  fi

  local pr_reactions
  pr_reactions="$(gh api "repos/$repo/issues/$pr/reactions" --paginate --slurp 2>/dev/null | jq 'add' || echo '[]')"

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

  local top_level_reviews actionable_top_level_reviews actionable_top_level_reviews_count
  top_level_reviews="$(jq -cn \
    --argjson reviews "$reviews" \
    --argjson issue_comments "$issue_comments" \
    --arg pattern "$codex_pattern" '
      [
        $reviews[]
        | select(.user.login | test($pattern; "i"))
        | select((.state // "") | ascii_downcase == "commented")
        | select((.body // "") != "")
        | . as $review
        | {
            id,
            submitted_at: (.submitted_at // .created_at // ""),
            user: .user.login,
            body,
            looks_actionable: ((.body // "") | test("(?i)(P[0-3] Badge|https://github.com/.*/blob/)")),
            has_matching_non_codex_reply_after: (
              [
                $issue_comments[]
                | select((.user.login | test($pattern; "i")) | not)
                | select((.created_at // "") > (($review.submitted_at // $review.created_at // "")))
                | select((.body // "") | contains(($review.id | tostring)))
              ]
              | length > 0
            )
          }
      ]
    ')"
  actionable_top_level_reviews="$(jq '[.[] | select(.looks_actionable and (.has_matching_non_codex_reply_after | not))]' <<<"$top_level_reviews")"
  actionable_top_level_reviews_count="$(jq 'length' <<<"$actionable_top_level_reviews")"

  jq -cn \
    --arg repo "$repo" \
    --argjson pr "$pr" \
    --arg codex_pattern "$codex_pattern" \
    --arg head_oid "$head_oid" \
    --arg head_committed_at "$head_committed_at" \
    --arg latest_trigger_time "$latest_trigger_time" \
    --arg latest_trigger_user "$latest_trigger_user" \
    --arg latest_trigger_head_oid "$latest_trigger_head_oid" \
    --arg latest_codex_event_time "$latest_codex_event_time" \
    --argjson pending_review "$pending_review" \
    --argjson trigger_reactions "$trigger_reactions" \
    --argjson pr_reactions "$pr_reactions" \
    --argjson issue_comments "$issue_comments" \
    --argjson codex_events "$codex_events" \
    --argjson actionable_diff_comments "$actionable_diff_roots" \
    --argjson actionable_diff_comments_count "$actionable_diff_count" \
    --argjson codex_top_level_reviews "$top_level_reviews" \
    --argjson actionable_top_level_reviews "$actionable_top_level_reviews" \
    --argjson actionable_top_level_reviews_count "$actionable_top_level_reviews_count" '
      ([
          $trigger_reactions[]
          | select(.content == "eyes")
          | select(.user.login | test($codex_pattern; "i"))
        ]) as $codex_trigger_eyes_reactions
      | ([
          $pr_reactions[]
          | select(.content == "eyes")
          | select(.user.login | test($codex_pattern; "i"))
        ]) as $codex_pr_eyes_reactions
      | ($codex_trigger_eyes_reactions | length > 0) as $has_codex_trigger_eyes
      | ($codex_pr_eyes_reactions | length > 0) as $has_codex_pr_eyes
      | ($has_codex_trigger_eyes or $has_codex_pr_eyes) as $has_codex_eyes
      | (($codex_trigger_eyes_reactions + $codex_pr_eyes_reactions) | sort_by(.created_at) | last.created_at // "") as $latest_codex_eyes_time
      | ([
          $trigger_reactions[]
          | select(.content == "+1")
          | select(.user.login | test($codex_pattern; "i"))
        ]) as $codex_trigger_thumbs_up_reactions
      | ([
          $pr_reactions[]
          | select(.content == "+1")
          | select(.user.login | test($codex_pattern; "i"))
        ]) as $codex_pr_thumbs_up_reactions
      | ($codex_trigger_thumbs_up_reactions | length > 0) as $has_codex_trigger_thumbs_up
      | ($codex_pr_thumbs_up_reactions | length > 0) as $has_codex_pr_thumbs_up
      | (($codex_trigger_thumbs_up_reactions + $codex_pr_thumbs_up_reactions) | sort_by(.created_at) | last.created_at // "") as $latest_codex_thumbs_up_time
      | (
          $codex_events | length > 0
          or $latest_trigger_time != ""
          or $has_codex_eyes
          or $has_codex_trigger_thumbs_up
          or $has_codex_pr_thumbs_up
        ) as $codex_review_required
      | ($latest_trigger_head_oid != "" and $latest_trigger_head_oid == $head_oid) as $latest_trigger_covers_head
      | ([
          $codex_events[]
          | select(.created_at >= $latest_trigger_time)
          | select(.user | test($codex_pattern; "i"))
        ] | length > 0) as $has_post_trigger_codex_activity
      | ([
          $codex_events[]
          | select(.kind == "issue_comment")
          | select(.created_at >= $latest_trigger_time)
          | select(.user | test($codex_pattern; "i"))
          | .id as $comment_id
          | $issue_comments[]
          | select(.id == $comment_id)
          | select((.body // "") | test("(?i)Codex Review: Didn.t find any major issues"))
        ] | length > 0) as $has_codex_clean_comment
      | (
          if (
            $latest_codex_eyes_time != ""
            and $latest_codex_eyes_time >= $head_committed_at
            and ($latest_trigger_time == "" or $latest_codex_eyes_time >= $latest_trigger_time)
          ) then $latest_codex_eyes_time
          else ""
          end
        ) as $active_codex_eyes_time
      | ([
          if $latest_trigger_time != "" then $latest_trigger_time else empty end,
          if $active_codex_eyes_time != "" then $active_codex_eyes_time else empty end
        ] | sort | last // "") as $codex_review_started_at
      | ([
          if ($latest_trigger_time != "" and $latest_trigger_covers_head) then $latest_trigger_time else empty end,
          if $active_codex_eyes_time != "" then $active_codex_eyes_time else empty end
        ] | sort | last // "") as $current_head_review_started_at
      | ([
          if $latest_codex_event_time != "" then $latest_codex_event_time else empty end,
          if $latest_codex_thumbs_up_time != "" then $latest_codex_thumbs_up_time else empty end
        ] | sort | last // "") as $latest_codex_completion_time
      | (
          ($has_codex_trigger_thumbs_up or $has_codex_pr_thumbs_up)
          and $current_head_review_started_at != ""
          and (
            $latest_codex_thumbs_up_time >= $current_head_review_started_at
            or ($latest_trigger_covers_head and $has_post_trigger_codex_activity)
            )
        ) as $has_current_head_approval
      | (
          $codex_review_started_at != ""
          and ($latest_codex_completion_time == "" or $latest_codex_completion_time < $codex_review_started_at)
        ) as $effective_pending_review
      | ($active_codex_eyes_time != "" and $effective_pending_review) as $eyes_pending_review
      | {
        repo: $repo,
        pr: $pr,
        codex_pattern: $codex_pattern,
        head: {
          oid: $head_oid,
          committed_at: (if $head_committed_at == "" then null else $head_committed_at end)
        },
        latest_trigger: {
          created_at: (if $latest_trigger_time == "" then null else $latest_trigger_time end),
          user: (if $latest_trigger_user == "" then null else $latest_trigger_user end),
          head_oid: (if $latest_trigger_head_oid == "" then null else $latest_trigger_head_oid end),
          reactions_count: ($trigger_reactions | length),
          has_codex_eyes: $has_codex_trigger_eyes,
          latest_codex_eyes_at: (if (($codex_trigger_eyes_reactions | sort_by(.created_at) | last.created_at // "") == "") then null else ($codex_trigger_eyes_reactions | sort_by(.created_at) | last.created_at) end),
          has_codex_thumbs_up: $has_codex_trigger_thumbs_up,
          latest_codex_thumbs_up_at: (if (($codex_trigger_thumbs_up_reactions | sort_by(.created_at) | last.created_at // "") == "") then null else ($codex_trigger_thumbs_up_reactions | sort_by(.created_at) | last.created_at) end),
          has_codex_clean_comment: $has_codex_clean_comment,
          covers_head: $latest_trigger_covers_head
        },
        pr_description: {
          reactions_count: ($pr_reactions | length),
          has_codex_thumbs_up: $has_codex_pr_thumbs_up,
          latest_codex_thumbs_up_at: (if (($codex_pr_thumbs_up_reactions | sort_by(.created_at) | last.created_at // "") == "") then null else ($codex_pr_thumbs_up_reactions | sort_by(.created_at) | last.created_at) end),
          has_codex_eyes: $has_codex_pr_eyes,
          latest_codex_eyes_at: (if (($codex_pr_eyes_reactions | sort_by(.created_at) | last.created_at // "") == "") then null else ($codex_pr_eyes_reactions | sort_by(.created_at) | last.created_at) end)
        },
        latest_codex_activity_at: (if $latest_codex_event_time == "" then null else $latest_codex_event_time end),
        codex_review_started_at: (if $codex_review_started_at == "" then null else $codex_review_started_at end),
        current_head_review_started_at: (if $current_head_review_started_at == "" then null else $current_head_review_started_at end),
        active_codex_eyes_at: (if $active_codex_eyes_time == "" then null else $active_codex_eyes_time end),
        latest_codex_completion_at: (if $latest_codex_completion_time == "" then null else $latest_codex_completion_time end),
        codex_review_required: $codex_review_required,
        has_codex_eyes: $has_codex_eyes,
        latest_codex_eyes_at: (if $latest_codex_eyes_time == "" then null else $latest_codex_eyes_time end),
        has_codex_thumbs_up: ($has_codex_trigger_thumbs_up or $has_codex_pr_thumbs_up),
        latest_codex_thumbs_up_at: (if $latest_codex_thumbs_up_time == "" then null else $latest_codex_thumbs_up_time end),
        eyes_pending_review: $eyes_pending_review,
        has_post_trigger_codex_activity: $has_post_trigger_codex_activity,
        main_thread_approved: ((($codex_review_required | not) or $has_current_head_approval)),
        pending_review: $effective_pending_review,
        actionable_diff_comments_count: $actionable_diff_comments_count,
        actionable_diff_comments: $actionable_diff_comments,
        codex_top_level_reviews: $codex_top_level_reviews,
        actionable_top_level_reviews_count: $actionable_top_level_reviews_count,
        actionable_top_level_reviews: $actionable_top_level_reviews,
        ready_for_codex: ((($effective_pending_review | not) and ($actionable_diff_comments_count == 0) and ($actionable_top_level_reviews_count == 0) and (($codex_review_required | not) or $has_current_head_approval)))
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

  require_cmd gh
  require_cmd jq

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
