---
name: linear
description: "Search and manage Linear issues. Use for listing issues, creating/updating issues, changing status, viewing issue details, or any Linear workflow."
---

# Linear CLI

Manage Linear issues from the command line using `linear` CLI.

## Quick Reference

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
linear issue update TC-123 -a lachlan
linear issue update TC-123 --priority 2

# Search (via list filters)
linear issue list --all-states --limit 100 | grep -i "search term"

# Projects & teams
linear project list
linear team list
linear team members
```

## Common Workflows

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

## State Values

- `triage` - Needs triage
- `backlog` - Backlog
- `unstarted` - Todo
- `started` - In Progress
- `completed` - Done
- `canceled` - Canceled

## Priority Values

- `1` - Urgent
- `2` - High
- `3` - Medium
- `4` - Low

## Direct GraphQL API

For queries not covered by CLI, use the API directly:

```bash
# Write schema to temp file for reference
linear schema -o /tmp/linear-schema.graphql

# Query with curl
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $(linear auth token)" \
  -d '{"query": "{ viewer { assignedIssues(first: 10) { nodes { identifier title } } } }"}'
```

## Full Command Reference

Run `linear --help` or `linear issue --help` for complete options.
