# Basic GitHub CLI Commands

## Pull Requests

### Create a pull request

```bash
gh pr create --title "My PR" --body "Description of changes"
```

### Create a draft pull request

```bash
gh pr create --title "WIP: Feature" --body "Work in progress" --draft
```

### List open pull requests

```bash
gh pr list
```

### View a pull request

```bash
gh pr view 123
gh pr view 123 --web  # Open in browser
```

### Check out a pull request locally

```bash
gh pr checkout 123
```

### Merge a pull request

```bash
gh pr merge 123 --squash
gh pr merge 123 --squash --delete-branch
```

## Issues

### Create an issue

```bash
gh issue create --title "Bug report" --body "Description"
```

### List issues

```bash
gh issue list
gh issue list --assignee @me
gh issue list --label bug
```

### View an issue

```bash
gh issue view 456
gh issue view 456 --web
```

### Close an issue

```bash
gh issue close 456
```

### Add a comment to an issue

```bash
gh issue comment 456 --body "My comment"
```

## Repository Operations

### Clone a repository

```bash
gh repo clone owner/repo
```

### View repository info

```bash
gh repo view
gh repo view owner/repo --web
```

### List repositories

```bash
gh repo list lightspeed-hospitality --limit 50
```

### Create a repository

```bash
gh repo create my-repo --private
```

## Releases

### List releases

```bash
gh release list
```

### View a release

```bash
gh release view v1.0.0
```

### Create a release

```bash
gh release create v1.0.0 --title "Release 1.0.0" --notes "Release notes"
```
