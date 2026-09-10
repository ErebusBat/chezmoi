#!/usr/bin/env bun

export {};

await Bun.stdin.text();

const child = Bun.spawn([
  "/usr/bin/curl",
  "-s",
  "wttr.in/casper%2Cwy?format=%c+%t",
], {
  stdin: "ignore",
  stdout: "pipe",
  stderr: "pipe",
});
const [output, , exitStatus] = await Promise.all([
  new Response(child.stdout).text(),
  new Response(child.stderr).text(),
  child.exited,
]);
const weather = exitStatus === 0 ? output.trim() : "";
console.log(
  JSON.stringify({
    action: "replace",
    value: `Casper, WY: ${weather}`,
  }),
);
