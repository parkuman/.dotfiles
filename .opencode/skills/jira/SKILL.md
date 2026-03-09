---
name: jira
description: Fetch and display Jira ticket information by ticket ID
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: jira
---

## What I do

- Fetch Jira ticket details (summary, description, status, assignee, priority, labels, etc.)
- Parse ticket IDs from user messages (e.g., "WFC-123", "PROJ-456")
- Display formatted ticket information in a readable format
- Handle multiple ticket lookups in a single request

## When to use me

Use this skill when:
- The user references a Jira ticket ID (like WFC-123, PROJ-456, etc.)
- The user explicitly asks to "look up", "check", "show", or "fetch" a Jira ticket
- The user wants to see details about a Jira issue

## How to fetch tickets

Use the Bash tool to call the Jira REST API. The API requires authentication via email and API token.

### Single Ticket Lookup

```bash
curl -s -u "${JIRA_USER}:${JIRA_TOKEN}" \
  -H "Content-Type: application/json" \
  "https://${JIRA_DOMAIN}/rest/api/3/issue/TICKET-ID"
```

Replace `TICKET-ID` with the actual ticket (e.g., WFC-123).

### Parse the JSON Response

The response includes fields like:
- `fields.summary` - Ticket title
- `fields.status.name` - Current status
- `fields.assignee.displayName` - Assigned person
- `fields.priority.name` - Priority level
- `fields.description` - Full description (can be long)
- `fields.labels` - Array of labels
- `fields.created` - Creation timestamp
- `fields.updated` - Last updated timestamp

### Environment Variables Required

These must be set in your shell environment:

- `JIRA_USER` - Your Jira account email (e.g., "parker@circleci.com")
- `JIRA_TOKEN` - Your Jira API token (generate at https://id.atlassian.com/manage-profile/security/api-tokens)
- `JIRA_DOMAIN` - Your Jira instance domain (e.g., "circleci.atlassian.net")

## How to format output

Present ticket information concisely for poopypants:

```
**[TICKET-ID]** - Summary text here

Status: In Progress | Assignee: John Doe | Priority: High
Labels: backend, bug, sprint-42

Description:
[First 300 chars of description or full if shorter]
[...truncated] if longer

Updated: 2 hours ago
Link: https://circleci.atlassian.net/browse/TICKET-ID
```

### For Multiple Tickets

If multiple ticket IDs are mentioned, fetch them all in parallel using multiple Bash calls, then format each one.

## Error Handling

- If ticket not found (404): "Ticket TICKET-ID not found in Jira"
- If auth fails (401): "Jira authentication failed - check JIRA_USER and JIRA_TOKEN env vars"
- If env vars missing: "Missing required env vars: JIRA_USER, JIRA_TOKEN, JIRA_DOMAIN"
- If API error: Show the error message from Jira

## Example Usage

User: "Can you check WFC-456?"

1. Load this skill
2. Extract ticket ID: WFC-456
3. Run curl command with env vars
4. Parse JSON response
5. Format and display output

User: "What's the status of PROJ-123 and PROJ-124?"

1. Load this skill
2. Extract ticket IDs: PROJ-123, PROJ-124
3. Run curl commands in parallel
4. Parse both responses
5. Format and display both outputs
