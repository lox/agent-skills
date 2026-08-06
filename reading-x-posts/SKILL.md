---
name: reading-x-posts
description: Reads x.com/twitter.com posts, quote posts, replies, and user-provided status IDs through the authenticated xurl CLI, with Birdclaw as an optional local fallback. Use when asked to read, summarize, inspect, quote, fetch, or explain an X/Twitter post or use authenticated X context.
---

# Reading X Posts

Use `xurl` for live single-post reads and Birdclaw for local Twitter/X memory.

## Workflow

Verify the local tools before assuming auth or flags are current:

```bash
command -v xurl
xurl --help
xurl auth status
xurl whoami
```

Use `xurl whoami` as the source of truth for the authenticated account. Before
reading account-sensitive data, report a surprising account mismatch without
assuming a fixed username.

Read a provided post URL or status ID directly:

```bash
xurl read "https://x.com/user/status/1234567890"
xurl read 1234567890
```

Use Birdclaw only when it is installed and the request needs cached/local context such as bookmarks,
likes, mentions, timelines, DMs, imported archive data, or research briefs:

```bash
birdclaw auth status
birdclaw db stats --json
birdclaw --json search tweets --limit 20 "query words"
birdclaw research "query words" --limit 20 --thread-depth 10 --json
```

Do not sync Birdclaw unless the user asks for refreshed local data. When syncing,
keep it bounded and force `xurl`:

```bash
birdclaw sync bookmarks --mode xurl --limit 100 --max-pages 5 --early-stop --refresh --json
```

Never run X write actions such as post, reply, like, repost, follow, block,
mute, bookmark, or DM unless the user explicitly asks for that action.

## Response Shape

- Include the author, handle, timestamp, post URL or ID, and post text or a
  faithful summary.
- Include quoted, replied-to, linked, or media context when the tool returns it.
- Distinguish original posts, replies, quote posts, and reposts when that context is available.
- Say whether the result came from live `xurl` or local `birdclaw`.
- If live auth, rate limit, or access fails, report the exact command and error,
  then try local Birdclaw cache only when it helps the request.
- If neither live nor cached access returns the post, say it could not be fetched;
  do not infer or invent its contents from surrounding context.
