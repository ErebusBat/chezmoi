#!/usr/bin/env node
// Routing tests only: never opens a browser or visits a URL.
import { readFile } from 'node:fs/promises';
import assert from 'node:assert/strict';

const source = await readFile(new URL('./finicky.js', import.meta.url), 'utf8');
const { default: config } = await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`);
const profileFor = (input) => {
  const url = new URL(input);
  const handler = config.handlers.find((h) => h.match.some((m) => m(url, { opener: null })));
  const target = handler?.browser ?? config.defaultBrowser;
  assert.equal(target.name, 'com.google.Chrome');
  assert.equal(target.appType, 'bundleId');
  return target.profile ?? '';
};

const work = 'lightspeedhq.com';
const personal = 'gmail';
export const cases = [
  ['https://lightspeed.onelogin.com/', work],
  ['https://onelogin.com/', work],
  ['https://notonelogin.com/', ''],
  ['https://onelogin.com.example.org/', ''],
  ['https://lightspeedhq.atlassian.net/', work],
  ['https://other.atlassian.net/', ''],
  ['https://upserve.atlassian.net/', work],
  ['https://foo.upserve.atlassian.net/', ''],
  ['https://developer.doordash.com/', work],
  ['https://www.developer.doordash.com/', work],
  ['https://api.developer.doordash.com/', ''],
  ['https://github.com/upserve/pos-service', work],
  ['http://www.github.com/Upserve/pos-service', work],
  ['https://github.com/dotswipely/swipely', work],
  ['https://github.com/swipely/relbot-2000', work],
  ['https://github.com/ls-andrew-burns', work],
  ['https://github.com/ErebusBat/project', personal],
  ['https://www.github.com/erebusbat/project', personal],
  ['https://github.com/johnste/finicky', ''],
  // Literal prefix semantics inherited from Velja, including suffix matches.
  ['https://github.com/upserve-extra/project', work],
  ['https://github.com/ErebusBat-extra/project', personal],
  ['https://groups.google.com/a/lightspeedhq.com', work],
  // The existing contains rule deliberately applies to query strings too.
  ['https://example.org/?next=lightspeedhq.com', work],
  ['https://d.erebusbat.net/', personal],
  ['https://erebusbat.net/', personal],
  ['https://noterebusbat.net/', ''],
  ['https://erebusbat.net.example.org/', ''],
  ['https://dash-maze.erebusbat.net/home/upserve', work],
  ['https://dash-maze.lan.erebusbat.net/home/upserve', work],
  ['https://www.dash-maze.erebusbat.net/home/upserve', work],
  ['https://dash-maze.erebusbat.net/home/personal', personal],
  // Velja's regex matching is case-sensitive, unlike its URL Prefix matching.
  ['https://dash-maze.erebusbat.net/HOME/UPSERVE', personal],
  ['https://www.perplexity.ai/', personal],
  ['https://mail.google.com/mail/u/?authuser=newjourneywy%40gmail.com#inbox', personal],
  ['https://mail.google.com/mail/u/?authuser=erebusbat%40gmail.com#inbox', personal],
  ['https://mail.google.com/mail/u/?authuser=other%40gmail.com#inbox', ''],
  ['https://mail.google.com/mail/u/?authuser=erebusbat%40gmail.com', ''],
  ['https://example.org/', ''],
];

assert.equal(config.handlers.length, 3);
assert.equal(config.handlers.reduce((n, h) => n + h.match.length, 0), 33);
for (const [input, expected] of cases) assert.equal(profileFor(input), expected, input);
console.log(`Passed ${cases.length} routing cases; 3 rules and 33 matchers present.`);
