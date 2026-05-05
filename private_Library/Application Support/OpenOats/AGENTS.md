# AGENTS.md

This document captures the repeatable workflow for cleaning post-meeting mic pickup from OpenOats transcripts.

## Scope

- Use this when a meeting ended, but extra personal speech was captured afterward.
- Default cleanup target is `transcript.final.jsonl` only (the file used for clean notes/export).

## Where OpenOats stores sessions

- Root: `~/Library/Application Support/OpenOats/sessions/`
- Session folder format: `session_YYYY-MM-DD_HH-MM-SS/`
- Typical transcript files per session:
  - `transcript.final.jsonl` (preferred cleanup target)
  - `transcript.live.jsonl`
  - `transcript.pre-batch.jsonl`

## Cleanup Procedure (Default)

1. Find the most recent session folder in `sessions/`.
2. Open `<session>/transcript.final.jsonl`.
3. Identify the actual meeting end (usually the last line from meeting participants).
4. Remove trailing post-meeting entries after that point.
5. Verify the file ends at the real meeting close and all remaining lines are valid JSON objects.

## Optional Extended Cleanup

- Only if specifically requested, apply the same trimming to:
  - `transcript.live.jsonl`
  - `transcript.pre-batch.jsonl`

This keeps all transcript artifacts aligned, but is not required for clean notes.

## Notes from 2026-05-05 Example

- Session: `session_2026-05-05_09-01-25`
- Cleaned: `transcript.final.jsonl`
- Removed trailing lines that were `speaker: "you"` after the standup ended.
