---
name: reading-x-posts
description: Reads x.com/twitter.com posts, quote posts, replies, and user-provided status IDs through the authenticated xurl CLI, with Birdclaw as an optional local fallback. Use when asked to read, summarize, inspect, quote, fetch, or explain an X/Twitter post or use authenticated X context.
---

# Reading X posts

Use `xurl` for live posts and Birdclaw for local Twitter or X data.

## Workflow

Check local tools and current authentication:

```bash
command -v xurl
xurl --help
xurl auth status
xurl whoami
```

Treat `xurl whoami` as the source of truth for the account. Before reading account-sensitive data, report a surprising account mismatch. Do not assume a fixed username.

Read a supplied URL or status ID directly:

```bash
xurl read "https://x.com/user/status/1234567890"
xurl read 1234567890
```

Use Birdclaw only when installed and the request needs cached or local bookmarks, likes, mentions, timelines, DMs, imported archives, or research briefs:

```bash
birdclaw auth status
birdclaw db stats --json
birdclaw --json search tweets --limit 20 "query words"
birdclaw research "query words" --limit 20 --thread-depth 10 --json
```

Sync Birdclaw only when the user asks for refreshed local data. Bound the sync and force `xurl`:

```bash
birdclaw sync bookmarks --mode xurl --limit 100 --max-pages 5 --early-stop --refresh --json
```

Never post, reply, like, repost, follow, block, mute, bookmark, or send a DM unless the user asks for that action.

## Response

Include the author, handle, timestamp, post URL or ID, and post text or a faithful summary. Include quoted, replied-to, linked, and media context returned by the tool. Distinguish original posts, replies, quote posts, and reposts when possible. Say whether the result came from live `xurl` or local `birdclaw`.

If live authentication, rate limits, or access fails, report the exact command and error. Try Birdclaw's local cache only when it helps. If neither source returns the post, say it could not be fetched. Do not infer or invent its contents.
