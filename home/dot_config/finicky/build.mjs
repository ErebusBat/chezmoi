#!/usr/bin/env node
// Rebuild Finicky's single runtime file after editing settings.json or rules.d/.
import { readFile, readdir, writeFile, rename } from 'node:fs/promises';
import assert from 'node:assert/strict';

const root = new URL('./', import.meta.url);
const readJSON = async (path) => JSON.parse(await readFile(new URL(path, root), 'utf8'));
const settings = await readJSON('settings.json');
const filenames = (await readdir(new URL('rules.d/', root)))
  .filter((name) => name.endsWith('.json')).sort();
const rules = await Promise.all(filenames.map((name) => readJSON(`rules.d/${name}`)));
assert(settings.defaultBrowser, 'settings.json requires defaultBrowser');

function compileMatcher({ kind, pattern }) {
  assert.equal(typeof pattern, 'string');
  assert(pattern.length > 0, 'Empty patterns are not allowed');
  const literal = JSON.stringify(pattern.toLowerCase());
  switch (kind) {
    case 'host':
      return `(url) => hostname(url) === ${literal}`;
    case 'domain':
      return `(url) => hostname(url) === ${literal} || hostname(url).endsWith(${JSON.stringify('.' + pattern.toLowerCase())})`;
    case 'prefix':
      return `(url) => matchURL(url).toLowerCase().startsWith(${literal})`;
    case 'contains':
      return `(url) => matchURL(url).toLowerCase().includes(${literal})`;
    case 'regex':
      new RegExp(pattern); // Reject invalid expressions before replacing the config.
      return `(url) => new RegExp(${JSON.stringify(pattern)}).test(matchURL(url))`;
    default:
      throw new Error(`Unknown matcher kind: ${kind}`);
  }
}

const handlers = rules.map((rule) => {
  assert(settings.targets[rule.target], `Unknown target in ${rule.name}: ${rule.target}`);
  assert(Array.isArray(rule.match) && rule.match.length, `No matchers in ${rule.name}`);
  return `    // ${rule.name.replace(/[\r\n]/g, ' ')}\n    {\n      match: [\n${rule.match.map((m) => `        ${compileMatcher(m)},`).join('\n')}\n      ],\n      browser: ${JSON.stringify(settings.targets[rule.target])},\n    },`;
});

const source = `// GENERATED: edit settings.json and rules.d/*.json, then run:
// node ~/.config/finicky/build.mjs
// Ported from Velja on 2026-10-15. First matching rule wins.
// This file is self-contained: Finicky does not need Node or runtime imports.

function matchURL(url) {
  // Velja removes the scheme and a leading www. before URL matching.
  return url.href.replace(/^[a-z][a-z0-9+.-]*:\\/\\//i, '').replace(/^www\\./i, '');
}

function hostname(url) {
  return url.hostname.toLowerCase().replace(/^www\\./, '');
}

export default {
  defaultBrowser: ${JSON.stringify(settings.defaultBrowser)},
  options: ${JSON.stringify(settings.options)},
  handlers: [
${handlers.join('\n')}
  ],
};
`;

// Syntax-check before atomically replacing the file watched by Finicky.
await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`);
await writeFile(new URL('finicky.js.tmp', root), source);
await rename(new URL('finicky.js.tmp', root), new URL('finicky.js', root));
console.log(`Built finicky.js: ${rules.length} rules, ${rules.reduce((n, r) => n + r.match.length, 0)} matchers.`);
