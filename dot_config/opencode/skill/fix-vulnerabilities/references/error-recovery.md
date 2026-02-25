# Error Recovery & Advanced Scenarios

## Handling Already-Fixed Vulnerabilities

For vulnerabilities already patched in the lockfile, ask the user before dismissing.

**Dismissal API call:**

```bash
gh api repos/{owner}/{repo}/dependabot/alerts/{number} \
  -X PATCH \
  -f state=dismissed \
  -f dismissed_reason=inaccurate \
  -f dismissed_comment="Vulnerability already patched in lockfile. Installed version: {version} >= patched version: {patched}"
```

## Monorepo Handling

If multiple `package.json` files exist (workspaces):

1. Identify which packages have vulnerabilities (from `manifest_path` in alert)
2. Group fixes by affected package
3. Handle each workspace's vulnerabilities separately if needed
4. Keep related fixes together when they affect the same vulnerability across packages

## Error Recovery

### Partial Success

If some fixes succeed and others fail, ask the user whether to:
- Commit successful fixes and document failures in summary
- Rollback everything and investigate failures first
- Show failure details before deciding

### Unexpected States

- If lockfile is corrupted after changes: Offer to restore from git and retry
- If package registry is down: Report and suggest retry later
- If vulnerability has no patched version: Report as "no fix available yet"

## Low Severity Follow-up

After reporting low severity issues, ask the user whether to:
- Fix them now
- Create a GitHub tracking issue
- Ignore for now (document in summary only)
- Review each individually
