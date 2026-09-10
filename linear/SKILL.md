---
name: linear
description: "Searches and manages Linear issues with the external linear CLI. Use when asked to find, view, create, update, assign, or change the status of Linear issues."
---

# Linear CLI

Manage Linear issues with the `linear` CLI.

## Requirements and safety

Check `command -v linear`, `linear --help`, and the authenticated workspace before relying on examples or changing issues. Do not start login or print an auth token unless the user asks for authentication help. Discover team keys, project names, workflow states, and the authenticated user with the installed CLI. Do not assume `ENG`, `TC-*`, or a fixed assignee.

Read an issue before updating it, and search before creating a likely duplicate. A request about one issue authorizes only the described update. Confirm bulk edits, reassignment to another person, destructive operations, and status changes with workflow side effects.

## Quick reference

```bash
# List issues
linear issue list                    # Your unstarted issues
linear issue list -s started         # Your in-progress issues
linear issue list --all-states       # All your issues
linear issue list -A                 # All assignees
linear issue list --team ENG         # Specific team
linear issue list --project "Q1"     # Filter by project

# View issue
linear issue view TC-123             # View issue details
linear issue view TC-123 --json      # JSON output

# Create issue
linear issue create -t "Title" -d "Description" --team ENG
linear issue create -t "Bug" -l "bug" -a self --priority 1

# Update issue
linear issue update TC-123 -s "In Progress"
linear issue update TC-123 -a self
linear issue update TC-123 --priority 2

# Search (via list filters)
linear issue list --all-states --limit 100 | grep -i "search term"

# Projects & teams
linear project list
linear team list
linear team members
```

## Common workflows

### Find issues by keyword
```bash
linear issue list --all-states --all-assignees --limit 100 | grep -i "keyword"
```

### Change issue status
```bash
linear issue update TC-123 -s "In Progress"
linear issue update TC-123 -s "Done"
```

### Create and start working
```bash
linear issue create -t "New feature" --start
```

### View with comments
```bash
linear issue view TC-123              # Includes comments by default
linear issue view TC-123 --no-comments
```

## State values

- `triage` - Needs triage
- `backlog` - Backlog
- `unstarted` - Todo
- `started` - In Progress
- `completed` - Done
- `canceled` - Canceled

## Priority values

- `1` - Urgent
- `2` - High
- `3` - Medium
- `4` - Low

## Direct GraphQL API

Use the API only when a necessary read-only query is missing from the CLI. Use CLI commands for mutations so their confirmation and validation remain active.

```bash
# Write schema to temp file for reference
linear schema -o /tmp/linear-schema.graphql

# Query with curl
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $(linear auth token)" \
  -d '{"query": "{ viewer { assignedIssues(first: 10) { nodes { identifier title } } } }"}'
```

Run `linear --help` or `linear issue --help` for all options.
