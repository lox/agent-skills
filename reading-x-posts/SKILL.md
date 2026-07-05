---
name: reading-x-posts
description: Read x.com/twitter.com posts, tweets, quote tweets, and user-provided post URLs through the authenticated xurl CLI, with Birdclaw as the local cache and research fallback. Use when asked to read, summarize, inspect, quote, fetch, or explain an X/Twitter post URL or status ID; when the user says to use their Twitter account; or when read-only Twitter/X context should come from xurl or Birdclaw instead of web search.
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

For this user's account, expect `xurl whoami` to show username `lox`. If another
account is active, report that before reading account-sensitive data.

Read a provided post URL or status ID directly:

```bash
xurl read "https://x.com/user/status/1234567890"
xurl read 1234567890
```

Use Birdclaw only when the request needs cached/local context such as bookmarks,
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
- Say whether the result came from live `xurl` or local `birdclaw`.
- If live auth, rate limit, or access fails, report the exact command and error,
  then try local Birdclaw cache only when it helps the request.
