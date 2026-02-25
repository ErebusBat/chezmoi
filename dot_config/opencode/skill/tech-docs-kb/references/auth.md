# Prerequisites & Authentication

## Verify Prerequisites

Run these checks using the Bash tool. If any fail, tell the user what to install and stop.

**Check AWS CLI v2:**

```bash
aws --version 2>&1 | grep -q "aws-cli/2" && echo "ok" || echo "fail: AWS CLI v2 required. Install with: brew install awscli"
```

**Check granted CLI:**

```bash
command -v granted &>/dev/null && echo "ok" || echo "fail: granted not installed. Install with: brew install common-fate/granted/granted"
```

## Authenticate

Check if credentials are valid, and if not, trigger SSO login — all from within OpenCode.

### Verify credentials

```bash
aws sts get-caller-identity --profile "lsk/dev/admin/eu-central-1" --region eu-central-1 --output json 2>&1
```

- **If it succeeds** (returns JSON with Account, Arn, UserId) — credentials are valid, proceed to search.
- **If it fails** (ExpiredToken, credential errors, or missing SSO token) — run SSO login:

### SSO login (runs from within OpenCode)

```bash
granted sso login --sso-start-url https://lightspeedhq.awsapps.com/start --sso-region us-west-2
```

This opens the user's browser for SSO authentication and caches the token in the macOS Keychain. Wait for it to complete (the command blocks until the browser flow finishes).

Then verify again:

```bash
aws sts get-caller-identity --profile "lsk/dev/admin/eu-central-1" --region eu-central-1 --output json 2>&1
```

If it still fails, instruct the user to check they have access to the `lsk/dev/admin/eu-central-1` role.

Do NOT proceed with KB queries until credentials are confirmed working.

## Handle Auth Errors

- **ExpiredTokenException / Invalid credentials / UnrecognizedClientException**: Re-run SSO login, then retry.
- **AccessDeniedException**: The user may not have the required role. Tell them to check their access.
- **ThrottlingException**: Wait 3 seconds and retry once.
