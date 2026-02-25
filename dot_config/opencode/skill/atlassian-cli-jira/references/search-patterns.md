# Advanced Search & Query Patterns

## Output Formats

**Table output (default):**

```bash
acli jira workitem search --jql "assignee = currentUser()"
```

**CSV output:**

```bash
acli jira workitem search --jql "project = TEAM" --fields "key,summary,assignee,status" --csv
```

**JSON output:**

```bash
acli jira workitem search --jql "project = TEAM" --json
```

**Count results:**

```bash
acli jira workitem search --jql "assignee = currentUser()" --count
```

## Pagination & Limits

```bash
# Get first 50 results
acli jira workitem search --jql "project = TEAM" --limit 50

# Get all results (paginate through them)
acli jira workitem search --jql "project = TEAM" --paginate
```

## Customize Fields

```bash
acli jira workitem search --jql "assignee = currentUser()" --fields "key,summary,priority,status,created"
```

Default fields: `issuetype,key,assignee,priority,status,summary`

## Saved Filters & Browser

```bash
# Search using saved filter
acli jira workitem search --filter 10001

# Open search results in browser
acli jira workitem search --jql "assignee = currentUser()" --web
```

## Real-World Examples

### Get all your open tasks

```bash
acli jira workitem search --jql "assignee = currentUser() AND status != Closed" --paginate
```

### Export team tickets to CSV

```bash
acli jira workitem search --jql "project = LSH AND updated >= -30d" --fields "key,summary,assignee,status,priority" --csv > team_tickets.csv
```

### Find stale tickets (not updated in 60 days)

```bash
acli jira workitem search --jql "updated < -60d AND status != Closed" --paginate
```

### Get all bugs in current sprint

```bash
acli jira workitem search --jql "sprint = OPEN AND type = Bug" --paginate
```

### Find high-priority tickets assigned to you

```bash
acli jira workitem search --jql "assignee = currentUser() AND priority = High" --paginate
```
