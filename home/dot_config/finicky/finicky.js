// GENERATED: edit settings.json and rules.d/*.json, then run:
// node ~/.config/finicky/build.mjs
// Ported from Velja on 2026-10-15. First matching rule wins.
// This file is self-contained: Finicky does not need Node or runtime imports.

function matchURL(url) {
  // Velja removes the scheme and a leading www. before URL matching.
  return url.href.replace(/^[a-z][a-z0-9+.-]*:\/\//i, '').replace(/^www\./i, '');
}

function hostname(url) {
  return url.hostname.toLowerCase().replace(/^www\./, '');
}

export default {
  defaultBrowser: {"name":"com.google.Chrome","appType":"bundleId"},
  options: {"keepRunning":true,"logRequests":false,"hideIcon":true},
  handlers: [
    // LightspeedHQ Dev
    {
      match: [
        (url) => new RegExp("^dash-\\w+\\.(lan\\.)?erebusbat\\.net/home/upserve").test(matchURL(url)),
        (url) => hostname(url) === "atlassian.com" || hostname(url).endsWith(".atlassian.com"),
        (url) => hostname(url) === "breadcrumb.com" || hostname(url).endsWith(".breadcrumb.com"),
        (url) => hostname(url) === "datadoghq.com" || hostname(url).endsWith(".datadoghq.com"),
        (url) => hostname(url) === "developer.doordash.com",
        (url) => hostname(url) === "figma.com" || hostname(url).endsWith(".figma.com"),
        (url) => matchURL(url).toLowerCase().startsWith("github.com/dotswipely"),
        (url) => matchURL(url).toLowerCase().startsWith("github.com/dotswipely/swipely"),
        (url) => matchURL(url).toLowerCase().startsWith("github.com/ls-andrew-burns"),
        (url) => matchURL(url).toLowerCase().startsWith("github.com/swipely"),
        (url) => matchURL(url).toLowerCase().startsWith("github.com/upserve"),
        (url) => matchURL(url).toLowerCase().startsWith("github.com/upserve"),
        (url) => matchURL(url).toLowerCase().startsWith("github.com/upserve/"),
        (url) => hostname(url) === "grid-lightspeedhq.enterprise.slack.com",
        (url) => hostname(url) === "honeybadger.io" || hostname(url).endsWith(".honeybadger.io"),
        (url) => hostname(url) === "honeybadger.io" || hostname(url).endsWith(".honeybadger.io"),
        (url) => hostname(url) === "jenkins.internal.upserve.com",
        (url) => hostname(url) === "lightspeedhq.atlassian.net",
        (url) => hostname(url) === "lightspeedhq.awsapps.com",
        (url) => matchURL(url).toLowerCase().includes("lightspeedhq.com"),
        (url) => hostname(url) === "lightspeedhq.slack.com",
        (url) => hostname(url) === "mylightspeed.org" || hostname(url).endsWith(".mylightspeed.org"),
        (url) => hostname(url) === "myworkday.com" || hostname(url).endsWith(".myworkday.com"),
        (url) => hostname(url) === "onelogin.com" || hostname(url).endsWith(".onelogin.com"),
        (url) => hostname(url) === "pagerduty.com" || hostname(url).endsWith(".pagerduty.com"),
        (url) => hostname(url) === "service-now.com" || hostname(url).endsWith(".service-now.com"),
        (url) => hostname(url) === "upserve.atlassian.net",
        (url) => hostname(url) === "upserve.com" || hostname(url).endsWith(".upserve.com"),
      ],
      browser: {"name":"com.google.Chrome","appType":"bundleId","profile":"lightspeedhq.com","openInBackground":false},
    },
    // ErebusBat.net
    {
      match: [
        (url) => hostname(url) === "erebusbat.net" || hostname(url).endsWith(".erebusbat.net"),
      ],
      browser: {"name":"com.google.Chrome","appType":"bundleId","profile":"gmail","openInBackground":false},
    },
    // Personal DEV
    {
      match: [
        (url) => matchURL(url).toLowerCase().startsWith("github.com/erebusbat"),
        (url) => matchURL(url).toLowerCase().startsWith("mail.google.com/mail/u/?authuser=erebusbat%40gmail.com#"),
        (url) => matchURL(url).toLowerCase().startsWith("mail.google.com/mail/u/?authuser=newjourneywy%40gmail.com#"),
        (url) => hostname(url) === "perplexity.ai" || hostname(url).endsWith(".perplexity.ai"),
      ],
      browser: {"name":"com.google.Chrome","appType":"bundleId","profile":"gmail","openInBackground":false},
    },
  ],
};
