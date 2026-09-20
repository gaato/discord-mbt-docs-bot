# discord-mbt-docs-bot

A Discord bot that searches the [discord.mbt](https://github.com/gaato/discord.mbt)
guide and public API, then posts the match in a Discord Components V2
container — built with discord.mbt itself.

`/docs <query>` autocompletes over every `##` section of the in-repo guide
(`src/guide/*.mbt.md` in discord.mbt) and replies with the section body and a
link to the rendered page on GitHub. Long sections paginate with `◀ ▶`
buttons (code fences are closed and reopened across page breaks), and `« »`
buttons step to the neighboring guide sections.

`/api <symbol>` autocompletes over public declarations from discord.mbt's
generated package interfaces. It shows the full signature, source docstring,
and a link to the declaration on GitHub. Long API entries paginate with the
same fence-aware `◀ ▶` controls as guide sections.

Button state lives entirely in the `custom_id`
(`docs:<page>:<section key>` or `api:<page>:<package alias>#<symbol>`), so
clicks survive bot restarts and need no per-conversation state — the same
handlers will work behind HTTP interactions or on serverless.

## Layout

- `src/docs` — the section index, search, and paging. `index_generated.mbt`
  is generated; the rest is hand-written.
- `src/api` — the generated public-symbol index, API search, and entry model.
- `src/gen` — the index generator. It parses guide headings, package interface
  files, and source docstrings, then emits both generated indexes.
- `src/ui` — the `/docs` and `/api` commands, pagination buttons, and component
  handlers.
- `src/app` — the shared `App` definition used by every executor below.
- `src/main` — the native Gateway executable.
- `src/worker` — the Cloudflare Workers adapter (HTTP interactions) plus
  `entry.js` and `wrangler.toml`.
- `src/register` — one-shot command registration for the Worker deployment,
  which has no startup phase to sync commands in.
- `src/endpoint` — one-shot inspection and management of Discord's
  Interactions Endpoint URL.

## Development

The bot depends on the published `gaato/discord` package. Only the index
generator reads a discord.mbt source checkout — the guide chapters and the
generated interfaces — and it expects a sibling checkout (the standard ghq
layout):

```
github.com/gaato/
├── discord.mbt/
└── discord-mbt-docs-bot/
```

Check out the tag that matches the `gaato/discord` version in `moon.mod`, so
the indexed guide and API describe the library the bot is built against.

Refresh discord.mbt's checked-in interfaces, then regenerate both indexes
after guide or public API changes:

```sh
moon info
moon run --target native --release src/gen
```

Test and run:

```sh
moon test --target native --release
env DISCORD_TOKEN=... moon run --target native --release src/main
```

Set `DISCORD_GUILD_ID` to sync the command to a single guild while developing
(global sync can take up to an hour to propagate).

The bot only needs the `applications.commands` and `bot` install scopes; it
subscribes to no privileged intents.

## Deploy to Cloudflare Workers

The Worker serves the same `App` over signed HTTP interactions — no Gateway
connection. Secrets come from Wrangler, not `.env`; the commands below copy
the token out of `.env` without echoing it (works in bash, zsh, and fish ≥ 3.4):

```sh
moon build --target js src/worker
cd src/worker
npx wrangler login   # once
env $(cat ../../.env) sh -c 'printf %s "$DISCORD_TOKEN" | npx wrangler secret put DISCORD_TOKEN'
printf %s "<public key from the developer portal>" | npx wrangler secret put DISCORD_PUBLIC_KEY
npx wrangler deploy
```

Then register the commands (Workers have no startup phase, so this is a
separate one-shot; it diff-syncs, so re-running is free):

```sh
env $(cat .env) moon run --target native --release src/register
```

Finally set the Worker URL as the application's **Interactions Endpoint URL**.
Run `set` only after `wrangler deploy`: Discord sends the URL a PING while
validating it. The `status` output also includes the `verify_key` needed for
the `DISCORD_PUBLIC_KEY` Wrangler secret.

```sh
env $(cat .env) moon run --target native --release src/endpoint            # show status
env $(cat .env) moon run --target native --release src/endpoint -- set https://<worker>.workers.dev
env $(cat .env) moon run --target native --release src/endpoint -- clear   # back to the Gateway
```

Once an endpoint URL is configured, Discord sends interactions there instead
of the Gateway, so the native `src/main` bot stops receiving them. `clear`
removes the endpoint and returns interaction delivery to Gateway operation
(`src/main`).
