#!/usr/bin/env bun

import { accessSync, constants } from "node:fs";
import { join } from "node:path";

interface SubstitutionRequest {
  readonly protocol: "dlog-substitution/v1";
  readonly fullEntryBeforeRule: string;
  readonly matchedText: string;
}

function isSubstitutionRequest(value: unknown): value is SubstitutionRequest {
  return (
    typeof value === "object" &&
    value !== null &&
    "protocol" in value &&
    value.protocol === "dlog-substitution/v1" &&
    "fullEntryBeforeRule" in value &&
    typeof value.fullEntryBeforeRule === "string" &&
    "matchedText" in value &&
    typeof value.matchedText === "string"
  );
}

const home = process.env["HOME"];
if (home === undefined) {
  throw new Error("HOME is not set");
}

const mode = process.argv[2];
if (mode !== "clipboard" && mode !== "match") {
  throw new Error(`Unknown markdown plugin mode: ${mode ?? "<missing>"}`);
}

const parsed: unknown = JSON.parse(await Bun.stdin.text());
if (!isSubstitutionRequest(parsed)) {
  throw new Error("Invalid dlog-substitution/v1 request");
}
const request = parsed;
const markdownTool = join(home, ".raycast-cmds", "markdown-tool.sh");

try {
  accessSync(markdownTool, constants.X_OK);
} catch {
  console.log(JSON.stringify({ action: "no-change" }));
  process.exit(0);
}

const arguments_ = mode === "match" ? [request.matchedText] : [];
const child = Bun.spawn([markdownTool, ...arguments_], {
  stdin: "ignore",
  stdout: "pipe",
  stderr: "pipe",
});
const [output, , status] = await Promise.all([
  new Response(child.stdout).text(),
  new Response(child.stderr).text(),
  child.exited,
]);

if (status !== 0) {
  console.log(
    JSON.stringify({
      action: "replace",
      value: `❌ MDT-ERROR: ${request.fullEntryBeforeRule}`,
    }),
  );
} else {
  console.log(
    JSON.stringify({
      action: "replace",
      value: output.trim(),
    }),
  );
}
