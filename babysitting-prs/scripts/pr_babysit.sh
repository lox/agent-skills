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
  state  Alias for codex-state.
  wait   Alias for codex-wait.
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

paginated_array() {
  gh api "$1" --paginate | jq -s 'add // []'
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
                isOutdated
                comments(first: 100) {
                  nodes {
                    databaseId
                    body
                    createdAt
                    path
                    line
                    url
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

  local rollup checks
  rollup="$(gh pr view "$pr" --repo "$repo" --json statusCheckRollup --jq '.statusCheckRollup // []')"
  checks="$(jq '
    [
      (. // [])[]
      | if .__typename == "CheckRun" then
          {
            name: (.name // ""),
            state: (.conclusion // .status // ""),
            bucket: (
              if ((.status // "") | ascii_upcase) != "COMPLETED" then "pending"
              elif ((.conclusion // "") | ascii_upcase) == "SKIPPED" then "skipping"
              elif ((.conclusion // "") | ascii_upcase) as $conclusion | ["SUCCESS", "NEUTRAL"] | index($conclusion) then "pass"
              elif ((.conclusion // "") | ascii_upcase) == "CANCELLED" then "cancel"
              else "fail"
              end
            ),
            link: (.detailsUrl // ""),
            workflow: (.workflowName // ""),
            timestamp: (.completedAt // .startedAt // "")
          }
        else
          {
            name: (.context // ""),
            state: (.state // ""),
            bucket: (
              if ((.state // "") | ascii_upcase) == "SUCCESS" then "pass"
              elif ((.state // "") | ascii_upcase) as $state | ["PENDING", "EXPECTED"] | index($state) then "pending"
              else "fail"
              end
            ),
            link: (.targetUrl // ""),
            workflow: "",
            timestamp: (.startedAt // "")
          }
        end
    ]
    | sort_by([.name, .workflow, .timestamp])
    | group_by([.name, .workflow])
    | map(last | del(.timestamp))
  ' <<<"$rollup")"

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

  local codex_unavailable_pattern='To use Codex here,.*create an environment'
  local codex_unavailable_comments latest_codex_unavailable_time
  codex_unavailable_comments="$(jq -cn \
    --argjson issue_comments "$issue_comments" \
    --arg pattern "$codex_pattern" \
    --arg unavailable_pattern "$codex_unavailable_pattern" '
      [
        $issue_comments[]
        | select(.user.login | test($pattern; "i"))
        | select((.body // "") | test($unavailable_pattern; "i"))
        | {kind:"issue_comment", id, created_at, user: .user.login, body}
      ]
      | sort_by(.created_at)
    ')"
  latest_codex_unavailable_time="$(jq -r 'last.created_at // empty' <<<"$codex_unavailable_comments")"

  local codex_events latest_codex_event_time
  codex_events="$(jq -cn \
    --argjson reviews "$reviews" \
    --argjson issue_comments "$issue_comments" \
    --argjson diff_comments "$diff_comments" \
    --arg pattern "$codex_pattern" \
    --arg unavailable_pattern "$codex_unavailable_pattern" '
      [
        ($reviews[] | select(.user.login | test($pattern; "i")) | {kind:"review", id, created_at: (.submitted_at // .created_at), user: .user.login, state}),
        ($issue_comments[] | select(.user.login | test($pattern; "i")) | select(((.body // "") | test($unavailable_pattern; "i")) | not) | {kind:"issue_comment", id, created_at, user: .user.login}),
        ($diff_comments[] | select(.user.login | test($pattern; "i")) | {kind:"diff_comment", id, created_at, user: .user.login, path, line})
      ]
      | sort_by(.created_at)
    ')"
  latest_codex_event_time="$(jq -r 'last.created_at // empty' <<<"$codex_events")"

  local latest_trigger_unavailable="false"
  if [[ -n "$latest_trigger_time" && -n "$latest_codex_unavailable_time" && "$latest_codex_unavailable_time" > "$latest_trigger_time" ]]; then
    latest_trigger_unavailable="true"
  fi

  local pending_review="false"
  if [[ -n "$latest_trigger_time" && "$latest_trigger_unavailable" == "false" ]]; then
    if [[ -z "$latest_codex_event_time" ]] || [[ "$latest_codex_event_time" < "$latest_trigger_time" ]]; then
      pending_review="true"
    fi
  fi

  local trigger_reactions='[]'
  if [[ -n "$latest_trigger_id" ]]; then
    trigger_reactions="$(gh api "repos/$repo/issues/comments/$latest_trigger_id/reactions" --paginate 2>/dev/null | jq -s 'add // []' || echo '[]')"
  fi

  local pr_reactions
  pr_reactions="$(gh api "repos/$repo/issues/$pr/reactions" --paginate 2>/dev/null | jq -s 'add // []' || echo '[]')"

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
    --arg latest_codex_unavailable_time "$latest_codex_unavailable_time" \
    --argjson pending_review "$pending_review" \
    --argjson latest_trigger_unavailable "$latest_trigger_unavailable" \
    --argjson trigger_reactions "$trigger_reactions" \
    --argjson pr_reactions "$pr_reactions" \
    --argjson issue_comments "$issue_comments" \
    --argjson codex_events "$codex_events" \
    --argjson codex_unavailable_comments "$codex_unavailable_comments" \
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
      | ($codex_trigger_eyes_reactions | sort_by(.created_at) | last.created_at // "") as $latest_codex_trigger_eyes_time
      | ($codex_pr_eyes_reactions | sort_by(.created_at) | last.created_at // "") as $latest_codex_pr_eyes_time
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
      | ($codex_pr_thumbs_up_reactions | sort_by(.created_at) | last.created_at // "") as $latest_codex_pr_thumbs_up_time
      | (
          $codex_events | length > 0
          or ($latest_trigger_time != "" and ($latest_trigger_unavailable | not))
          or $has_codex_eyes
          or $has_codex_trigger_thumbs_up
          or $has_codex_pr_thumbs_up
        ) as $codex_review_required
      | (($codex_unavailable_comments | length > 0) and ($codex_review_required | not)) as $codex_review_unavailable
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
            $latest_codex_trigger_eyes_time != ""
            and $latest_trigger_covers_head
            and $latest_codex_trigger_eyes_time >= $latest_trigger_time
          ) then $latest_codex_trigger_eyes_time
          else ""
          end
        ) as $active_trigger_eyes_time
      | (
          if (
            $latest_codex_pr_eyes_time != ""
            and $latest_codex_pr_eyes_time >= $head_committed_at
          ) then $latest_codex_pr_eyes_time
          else ""
          end
        ) as $active_pr_eyes_time
      | ([
          if $active_trigger_eyes_time != "" then $active_trigger_eyes_time else empty end,
          if $active_pr_eyes_time != "" then $active_pr_eyes_time else empty end
        ] | sort | last // "") as $active_codex_eyes_time
      | ([
          if ($latest_trigger_time != "" and ($latest_trigger_unavailable | not)) then $latest_trigger_time else empty end,
          if $active_codex_eyes_time != "" then $active_codex_eyes_time else empty end
        ] | sort | last // "") as $codex_review_started_at
      | ([
          if ($latest_trigger_time != "" and $latest_trigger_covers_head and ($latest_trigger_unavailable | not)) then $latest_trigger_time else empty end,
          if $active_codex_eyes_time != "" then $active_codex_eyes_time else empty end
        ] | sort | last // "") as $current_head_review_started_at
      | ([
          if $latest_codex_event_time != "" then $latest_codex_event_time else empty end,
          if $latest_codex_thumbs_up_time != "" then $latest_codex_thumbs_up_time else empty end
        ] | sort | last // "") as $latest_codex_completion_time
      | (
          ($has_codex_trigger_thumbs_up or $has_codex_pr_thumbs_up)
          and $current_head_review_started_at != ""
          and $latest_codex_thumbs_up_time >= $current_head_review_started_at
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
        latest_codex_unavailable_at: (if $latest_codex_unavailable_time == "" then null else $latest_codex_unavailable_time end),
        codex_review_unavailable: $codex_review_unavailable,
        codex_unavailable_comments_count: ($codex_unavailable_comments | length),
        codex_unavailable_comments: $codex_unavailable_comments,
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
            is_outdated: .isOutdated,
            first_comment_id: (.comments.nodes[0].databaseId // null),
            user: (.comments.nodes[0].author.login // null),
            body: ((.comments.nodes[0].body // "") | .[0:300]),
            comments: [
              .comments.nodes[]
              | {
                  id: .databaseId,
                  user: (.author.login // null),
                  body,
                  created_at: .createdAt,
                  path,
                  line,
                  url
                }
            ]
          }
      ]
    }
  '
}

top_level_reviews_json() {
  local repo="$1"
  local pr="$2"
  local codex_pattern="$3"

  local reviews issue_comments
  reviews="$(paginated_array "repos/$repo/pulls/$pr/reviews")"
  issue_comments="$(paginated_array "repos/$repo/issues/$pr/comments")"

  jq -cn \
    --argjson reviews "$reviews" \
    --argjson issue_comments "$issue_comments" \
    --arg codex_pattern "$codex_pattern" '
      [
        $reviews[]
        | select((.state // "") != "PENDING" and (.state // "") != "DISMISSED")
        | select((.body // "") != "")
        | select((.user.login // "") | test($codex_pattern; "i") | not)
      ] as $submitted_reviews
      | [
          $submitted_reviews[]
          | . as $review
          | {
              id: $review.id,
              state: $review.state,
              submitted_at: ($review.submitted_at // $review.created_at),
              user: $review.user.login,
              body: $review.body,
              acknowledged: ([
                $issue_comments[]
                | select((.body // "") | contains("for review \($review.id):"))
              ] | length > 0),
              superseded_by_approval: ([
                $submitted_reviews[]
                | select(.user.login == $review.user.login)
                | select((.submitted_at // .created_at // "") > ($review.submitted_at // $review.created_at // ""))
                | select(.state == "APPROVED")
              ] | length > 0)
            }
        ] as $classified_reviews
      | [
          $classified_reviews[]
          | select(.state == "COMMENTED" or .state == "CHANGES_REQUESTED")
          | select(.acknowledged | not)
          | select(.superseded_by_approval | not)
        ] as $unacknowledged
      | {
          submitted_reviews: $classified_reviews,
          unacknowledged_top_level_reviews_count: ($unacknowledged | length),
          unacknowledged_top_level_reviews: $unacknowledged
        }
    '
}

status_json() {
  local repo="$1"
  local pr="$2"
  local codex_pattern="$3"

  local pr_meta checks threads top_level_reviews codex
  pr_meta="$(gh pr view "$pr" --repo "$repo" --json number,url,title,state,isDraft,headRefName,baseRefName,headRefOid,mergeable,mergeStateStatus,reviewDecision,reviewRequests,latestReviews,author)"
  checks="$(checks_json "$repo" "$pr")"
  threads="$(review_threads_json "$repo" "$pr")"
  top_level_reviews="$(top_level_reviews_json "$repo" "$pr" "$codex_pattern")"
  codex="$(state_json "$repo" "$pr" "$codex_pattern")"

  jq -cn \
    --argjson pr "$pr_meta" \
    --argjson checks "$checks" \
    --argjson threads "$threads" \
    --argjson top_level_reviews "$top_level_reviews" \
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
        if $top_level_reviews.unacknowledged_top_level_reviews_count > 0 then "unacknowledged_top_level_reviews" else empty end,
        if $codex.pending_review == true then "pending_codex_review" else empty end,
        if $codex.actionable_diff_comments_count > 0 then "actionable_codex_comments" else empty end,
        if $codex.actionable_top_level_reviews_count > 0 then "actionable_codex_top_level_reviews" else empty end,
        if ((($codex.codex_review_unavailable // false) | not) and ($codex.pending_review | not) and $codex.codex_review_required == true and $codex.main_thread_approved == false) then "codex_thumbs_up_missing" else empty end,
        if $checks.any_failed == true then "failed_checks" else empty end,
        if $checks.any_pending == true then "pending_checks" else empty end
      ] as $blockers
      | {
          pr: $pr,
          checks: $checks,
          review_threads: $threads,
          top_level_reviews: $top_level_reviews,
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
    status)
      status_json "$repo" "$pr" "$codex_pattern"
      ;;
    codex-state|state)
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
    codex-wait|wait)
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
