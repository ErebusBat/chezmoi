# Finicky rules migrated from Velja

Migrated 2026-10-15 from the installed Velja 3.2.4 preferences. All three enabled custom rules and all 33 matchers are preserved, including duplicates and original rule order.

## Files

- `settings.json`: default browser, options, and named profile targets.
- `rules.d/10-work.json`: LightspeedHQ Dev → Chrome `lightspeedhq.com` (`Default`).
- `rules.d/20-erebusbat.json`: ErebusBat.net → Chrome `gmail` (`Profile 1`).
- `rules.d/30-personal.json`: Personal DEV → Chrome `gmail` (`Profile 1`).
- `finicky.js`: generated, self-contained Finicky v4 configuration.
- `build.mjs`: converts the editable JSON files into `finicky.js`, with rules ordered by filename.
- `test.mjs`: routing regression checks that do not open browsers or visit websites.

After editing the JSON files:

```sh
cd ~/.config/finicky
just edit   # Open settings and all rule files in $VISUAL/$EDITOR (fallback: nvim).
just build  # Generate finicky.js.
just test   # Rebuild and run routing checks.
just chezmoi # Rebuild, test, and add the entire directory to chezmoi.
```

`just edit-rule 30-personal.json` opens one rule file. The editor setting is an
executable name or path; override it with `just EDITOR=nvim edit` if needed.
Run `just` to list recipes. The underlying `node build.mjs` and `node test.mjs`
commands remain available.

`just chezmoi` imports the settings, rules, generated config, build/test scripts,
README, and justfile into chezmoi's source state. It also updates already-managed
copies with the current local files. Chezmoi's configured Git automation applies.

Finicky v4.2.2 searches `~/.config/finicky/finicky.js` automatically. Files such as `~/.finicky.js`, `~/.finicky.ts`, `~/.config/finicky.js`, and `~/.config/finicky.ts` take precedence, as does an explicitly selected custom path. No higher-priority config was found during migration.

The generated config has no runtime imports. This makes every rule edit visible to Finicky through the rebuilt entrypoint, avoiding imported-file cache/watcher limitations. Node is needed only to rebuild and run tests.

## Preserved behavior

- First matching rule wins. The work dashboard regex is evaluated before the general personal `erebusbat.net` rule.
- Unmatched URLs go to Chrome without selecting a profile, matching Velja's `browser:com.google.Chrome` default. This is not a forced personal-profile fallback.
- Profile display names were checked against Chrome's Local State file and their original Velja directory targets. Update `settings.json` if the profile names change.
- Scheme and leading `www.` are removed for URL matching. Prefix and contains checks ignore case. The dashboard regular expression remains case-sensitive; this was checked in Velja's rule editor using an unsaved sample.
- `domain` checks match a domain and its subdomains, with a dot boundary. The imported `upserve.atlassian.net` Domain matcher is represented as an exact `host` match to preserve Velja's documented treatment of a pattern that already contains a subdomain.
- Existing broad prefix/substring rules are unchanged: `github.com/upserve` also matches `github.com/upserve-extra`; `lightspeedhq.com` can match anywhere in a URL. Gmail prefixes still require the original query order and `#` character.
- No URL rewrites or source-app restrictions were present in the three custom rules. Background opening and forced new windows were disabled. The hidden menu icon preference is retained.

## Scope and activation

This ports the custom Rules list and the default browser. Velja's separate built-in Apps behavior is not included: Telegram, Spotify, Discord, App Store and Zoom app handoffs; Google Meet and Microsoft Teams work-profile selection; and Apple Music links to Safari. Velja's built-in URL cleanup/redirect expansion and browser picker are also separate features and are not reproduced here.

Finicky was not installed or made the system default during this migration. Install it and choose it as your default browser when ready to activate this configuration. Velja's saved rules were not modified.

## Verification

38 regression cases cover profile routing, domain boundaries, exact hosts, case handling, scheme/www normalization, Gmail prefixes, rule precedence and the unqualified Chrome fallback. The config was additionally checked using Finicky v4.2.2's own config API, including the 32 non-empty sample URLs stored in Velja. Original sample URLs were evaluated in memory and were not copied into these files, since some contained authentication parameters.

This verifies configuration and routing logic. Actual browser-launch behavior remains to be checked after Finicky is installed.

Sources: [Finicky v4 documentation](https://github.com/johnste/finicky/wiki/Configuration-%28v4%29), [v4.2.2 config loading](https://github.com/johnste/finicky/blob/v4.2.2/apps/finicky/src/config/configfiles.go), and the installed Velja rule editor's matcher help.
