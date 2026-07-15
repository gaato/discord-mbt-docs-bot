# discord-mbt-docs-bot

A Discord bot that searches the [discord.mbt](https://github.com/gaato/discord.mbt)
guide and posts the matching section as an embed — built with discord.mbt itself.

`/docs <query>` autocompletes over every `##` section of the in-repo guide
(`src/guide/*.mbt.md` in discord.mbt) and replies with the section body and a
link to the rendered page on GitHub. Long sections paginate with `◀ ▶`
buttons (code fences are closed and reopened across page breaks), and `« »`
buttons step to the neighboring guide sections.

Button state lives entirely in the `custom_id`
(`docs:<page>:<section key>`), so clicks survive bot restarts and need no
per-conversation state — the same handlers will work behind HTTP
interactions or on serverless.

## Layout

- `src/docs` — the section index, search, and paging. `index_generated.mbt`
  is generated; the rest is hand-written.
- `src/gen` — the index generator. It parses the guide chapters by heading and
  emits `src/docs/index_generated.mbt`.
- `src/ui` — the `/docs` command, pagination buttons, and component handler.
- `src/app` — the shared `App` definition used by every executor below.
- `src/main` — the native Gateway executable.
- `src/worker` — the Cloudflare Workers adapter (HTTP interactions) plus
  `entry.js` and `wrangler.toml`.
- `src/register` — one-shot command registration for the Worker deployment,
  which has no startup phase to sync commands in.

## Development

discord.mbt is not published yet, so the module is resolved through the
`moon.work` workspace, which expects a sibling checkout (the standard ghq
layout):

```
github.com/gaato/
├── discord.mbt/
└── discord-mbt-docs-bot/
```

Regenerate the index after the guide changes:

```sh
moon run --target native --release src/gen
```

Test and run:

```sh
moon test --target native --release
DISCORD_TOKEN=... moon run --target native --release src/main
```

Set `DISCORD_GUILD_ID` to sync the command to a single guild while developing
(global sync can take up to an hour to propagate).

The bot only needs the `applications.commands` and `bot` install scopes; it
subscribes to no privileged intents.

## Deploy to Cloudflare Workers

The Worker serves the same `App` over signed HTTP interactions — no Gateway
connection. Secrets come from Wrangler, not `.env`; the commands below copy
the token out of `.env` without echoing it (fish syntax):

```fish
moon build --target js src/worker
cd src/worker
npx wrangler login   # once
env (cat ../../.env) sh -c 'printf %s "$DISCORD_TOKEN" | npx wrangler secret put DISCORD_TOKEN'
printf %s "<public key from the developer portal>" | npx wrangler secret put DISCORD_PUBLIC_KEY
npx wrangler deploy
```

Then register the commands (Workers have no startup phase, so this is a
separate one-shot; it diff-syncs, so re-running is free):

```fish
env (cat .env) moon run --target native --release src/register
```

Finally set the Worker URL as the **Interactions Endpoint URL** in the Discord
developer portal. Note that once an endpoint URL is configured, Discord sends
interactions there instead of the Gateway, so the native `src/main` bot stops
receiving them until the URL is cleared again.

Known issue: `moonbitlang/async` on the JS target needs the one-line
`js_async` scheduler fix from
[moonbitlang/async#500](https://github.com/moonbitlang/async/pull/500) until
it is released upstream. It is applied to `.mooncakes/` in this checkout;
re-fetching dependencies reverts it, so re-apply the patch if deferred
handlers stop resuming on Workers.
