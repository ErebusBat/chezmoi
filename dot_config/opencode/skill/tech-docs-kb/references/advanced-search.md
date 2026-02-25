# Advanced Search & Document Retrieval

## Metadata Filters

If the question clearly maps to a specific area or document type, add a metadata filter to narrow results before vector search.

```bash
aws bedrock-agent-runtime retrieve \
  --knowledge-base-id S3WJX83IGW \
  --retrieval-query '{"text": "QUERY"}' \
  --retrieval-configuration '{
    "vectorSearchConfiguration": {
      "numberOfResults": 5,
      "overrideSearchType": "HYBRID",
      "filter": {"equals": {"key": "area", "value": "Infrastructure"}}
    }
  }' \
  --profile "lsk/dev/admin/eu-central-1" \
  --region eu-central-1 \
  --output json \
  --no-cli-pager
```

**Filter mapping hints:**

| Question mentions... | Filter |
| --- | --- |
| ADR, architecture decision | `{"equals": {"key": "doc_type", "value": "adr"}}` |
| RFC, proposal | `{"equals": {"key": "doc_type", "value": "rfc"}}` |
| incident, rollback, SEV | `{"equals": {"key": "area", "value": "Incidents"}}` |
| deploy, sandbox, CI/CD | `{"equals": {"key": "area", "value": "Development"}}` |
| Kafka, Kubernetes, DR | `{"equals": {"key": "area", "value": "Infrastructure"}}` |
| tutorial, how to choose | `{"equals": {"key": "area", "value": "Tutorials"}}` |

**Combine filters** with `andAll`:

```json
{
  "filter": {
    "andAll": [
      {"equals": {"key": "doc_type", "value": "rfc"}},
      {"equals": {"key": "status", "value": "Approved"}}
    ]
  }
}
```

**Note:** Filters only work if metadata sidecar files exist in S3. If the filter returns zero results, retry without the filter — the metadata may not be populated yet.

## Fetch Full Documents from S3

Search results return text **chunks** (~200-500 tokens each), not full documents. After reviewing search results, fetch the full document from S3 for any high-relevance source.

### When to fetch (do this by default)

Fetch the full document when **any** of these apply:

- The top result has a **relevance score >= 0.4**
- The question asks about a **process, procedure, or architecture**
- **Multiple chunks** point to the **same document**
- The chunk references **sections, steps, or details** not included in the chunk text
- The document is an **RFC, ADR, runbook, or tutorial**

### When you can skip the full fetch

- The question is simple and a single chunk fully answers it
- The chunk contains a self-contained table, list, or definition
- All relevance scores are **below 0.3**

### Stream to stdout (preferred — no file saved to disk)

```bash
aws s3 cp s3://tech-docs-knowledge-base/docs/Projects/POS/blockchain.md - \
  --profile "lsk/dev/admin/eu-central-1" \
  --region eu-central-1
```

### Fetch multiple documents in parallel

When search results identify 2-3 relevant source documents, fetch them as separate Bash tool calls in the same message.

### Extract S3 URIs from search results

The S3 URI is in each result's `location.s3Location.uri` field. Strip the bucket prefix to get the repo-relative path:
- `s3://tech-docs-knowledge-base/docs/Architecture/Auth/01-authorization.md` -> `docs/Architecture/Auth/01-authorization.md`

### Notes

- The S3 URI maps directly to the tech-docs repo path: `s3://tech-docs-knowledge-base/docs/...` -> `docs/...` in `lightspeed-hospitality/tech-docs`
- PDF files will be binary — save to a file instead: `aws s3 cp <URI> /tmp/doc.pdf --profile "lsk/dev/admin/eu-central-1" --region eu-central-1`
- If the fetch fails with **AccessDenied**, the assumed role may not have `s3:GetObject` on the bucket
- **Budget:** Aim to fetch 1-3 full documents per query. If you're fetching more than 5, narrow your search first.

## Multi-turn Search

For complex questions, run multiple searches sequentially:

1. **Broad search first** — HYBRID, 8 results, using the user's original question (reformulated)
2. **Narrow search second** — HYBRID, 3 results, using specific terms discovered in step 1
3. **Synthesize** from both result sets

Only do multi-turn when the first search doesn't give a clear answer.
