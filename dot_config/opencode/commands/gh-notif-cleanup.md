---
name: gh-notif-cleanup
description: Mark review-requested notifications done when PRs are closed/merged
---

<objective>
Mark review-requested notifications as done if their PR is closed or merged.

Print a summary of how many were checked and marked.
</objective>

<tasks>
<task type="auto">
Run the script below using gh + GraphQL to:
- list review-requested PR notifications (including read)
- resolve PR states by repo/number
- mark matching threads read
- print counts
</task>
</tasks>

```bash
python3 - <<'PY'
import json, re, subprocess

def gh_api(args):
    return subprocess.check_output(["gh", "api", *args])

notes = json.loads(gh_api(["notifications?all=true", "--paginate"]))

review_prs = []
for n in notes:
    if n.get("reason") != "review_requested":
        continue
    subj = n.get("subject") or {}
    if subj.get("type") != "PullRequest":
        continue
    url = subj.get("url")
    if not url:
        continue
    m = re.search(r"/repos/([^/]+)/([^/]+)/pulls/(\d+)$", url)
    if not m:
        continue
    owner, repo, number = m.group(1), m.group(2), int(m.group(3))
    review_prs.append({
        "thread_id": n.get("id"),
        "owner": owner,
        "repo": repo,
        "number": number,
        "unread": n.get("unread"),
    })

merged_or_closed = []
batch_size = 20
for i in range(0, len(review_prs), batch_size):
    batch = review_prs[i:i+batch_size]
    parts = []
    for idx, item in enumerate(batch):
        alias = f"pr{idx}"
        parts.append(
            f"{alias}: repository(owner: \"{item['owner']}\", name: \"{item['repo']}\") "
            f"{{ pullRequest(number: {item['number']}) {{ merged state }} }}"
        )
    query = "query {\n" + "\n".join(parts) + "\n}"
    data = json.loads(gh_api(["graphql", "-f", f"query={query}"]))
    for idx, item in enumerate(batch):
        alias = f"pr{idx}"
        repo_node = (data.get("data") or {}).get(alias) or {}
        pr = repo_node.get("pullRequest")
        if not pr:
            continue
        if pr.get("merged") or pr.get("state") == "CLOSED":
            merged_or_closed.append(item)

marked = 0
for t in merged_or_closed:
    if t.get("thread_id"):
        gh_api(["-X", "PATCH", f"/notifications/threads/{t['thread_id']}"])
        marked += 1

print(f"Checked: {len(review_prs)} review-requested, marked read: {marked}")
PY
```
