---
name: birdclaw
description: Operate Birdclaw, the local-first Twitter/X memory CLI and web app backed by SQLite, plus xurl for direct X API reads. Use when asked to read x.com/twitter.com post URLs or post IDs, set up or troubleshoot Birdclaw, inspect its local store, sync or read bookmarks/likes/mentions/timelines/DMs, use xurl or bird transports, import a Twitter archive, start the local Birdclaw UI, or build bookmark research briefs.
---

# Birdclaw

Birdclaw is a local-first Twitter/X workspace. Prefer local reads from its SQLite cache; use live X reads only when the user asks to sync or refresh data.

## First Checks

Run these before assuming docs or memory are current:

```bash
command -v birdclaw
birdclaw --version
birdclaw --help
birdclaw auth status
birdclaw db stats --json
```

Birdclaw moves quickly. Trust the installed CLI help for flags. Upstream docs sometimes show source-checkout commands like `pnpm cli ...`; with the installed Homebrew CLI, use `birdclaw ...`.

## Transport Rules

- `xurl` is the normal OAuth-backed path for live reads such as bookmarks, likes, authored tweets, and mentions.
- `bird` is optional and cookie-backed. If `bird` is not installed, do not let `auto` mode hide that failure; force `--mode xurl`.
- Do not run live write actions such as post, reply, block, mute, or DM unless the user explicitly asks.
- Check `xurl` separately when auth looks suspicious:

```bash
xurl auth status
xurl whoami
```

If Birdclaw targets the wrong account, inspect the local account row before syncing:

```bash
sqlite3 ~/.birdclaw/birdclaw.sqlite "select id, name, handle, external_user_id, transport, is_default from accounts;"
```

## Read X.com Posts

For a user-provided `x.com` or `twitter.com` post URL, extract the numeric status id from `/status/<id>` or `/i/web/status/<id>` and read it through `xurl`:

```bash
xurl read 1234567890123456789
```

Use this for direct post reads before doing any Birdclaw sync. Only sync into Birdclaw when the user asks to refresh a timeline, bookmark lane, archive-backed cache, or research set.

## Bookmark Workflow

For a quick read-only live smoke:

```bash
xurl bookmarks -n 5
```

For Birdclaw bookmark sync, start bounded and force `xurl`:

```bash
birdclaw sync bookmarks --mode xurl --limit 5 --max-pages 1 --json
```

For a useful refresh without an unbounded crawl:

```bash
birdclaw sync bookmarks --mode xurl --limit 100 --all --max-pages 5 --early-stop --refresh --json
```

Then read locally:

```bash
birdclaw --json search tweets --bookmarked --limit 20
birdclaw research "query words" --limit 20 --thread-depth 10 --json
```

Use `--refresh` only when deliberately spending live reads. For repeated syncs, prefer `--early-stop` so Birdclaw stops after a fully cached page.

## Web UI

Start the local app:

```bash
birdclaw serve
```

The installed app commonly serves `http://localhost:3000`. If the command does not print a URL, find it:

```bash
lsof -nP -iTCP -sTCP:LISTEN | rg 'birdclaw|node|vite'
```

Useful routes:

```text
http://localhost:3000/bookmarks
http://localhost:3000/likes
http://localhost:3000/mentions
http://localhost:3000/dms
```

## Archive Import

If the user has a Twitter archive, import it instead of trying to reconstruct history with live API calls:

```bash
birdclaw archive find --json
birdclaw import archive /path/to/twitter-archive.zip --json
birdclaw import archive /path/to/twitter-archive.zip --select likes,bookmarks --json
```

Archive import is local DB work. Optional profile hydration performs live X profile reads and can spend API credits:

```bash
birdclaw import hydrate-profiles --json
```

## Local Store

Default paths:

```text
~/.birdclaw/birdclaw.sqlite
~/.birdclaw/media
~/.birdclaw/audit/bookmarks-sync.jsonl
```

Override the root only when the task calls for isolated state:

```bash
export BIRDCLAW_HOME=/path/to/root
```

Before manual SQLite edits, copy the DB:

```bash
cp ~/.birdclaw/birdclaw.sqlite ~/.birdclaw/birdclaw.sqlite.$(date +%Y%m%d-%H%M%S).bak
```

If seeded demo bookmarks pollute bookmark reads, clear only legacy demo bookmark state after backing up:

```bash
sqlite3 ~/.birdclaw/birdclaw.sqlite "
  update tweets set bookmarked = 0 where id like 'tweet_%';
  delete from tweet_collections where kind = 'bookmarks' and source = 'legacy' and tweet_id like 'tweet_%';
"
```

## Background Sync

Use the job command for auditable bookmark refreshes:

```bash
birdclaw --json jobs sync-bookmarks --mode xurl --limit 100 --max-pages 5 --refresh
tail -n 5 ~/.birdclaw/audit/bookmarks-sync.jsonl | jq .
```

Install or modify launchd jobs only when the user asks for recurring sync.

## Troubleshooting

- `bird: not found`: rerun with `--mode xurl` or install/configure `bird` only if the user wants cookie-backed transport.
- X `CreditsDepleted`: local setup is fine; live API reads are blocked by the X developer account.
- Unauthorized from `xurl`: check `xurl auth status`; set the correct default app with `xurl auth default APP_NAME`.
- Wrong user id in live endpoint: fix the Birdclaw `accounts.external_user_id`/handle or import the user's archive.
- `database is locked`: avoid running multiple Birdclaw commands against the same SQLite DB in parallel; retry sequentially.
