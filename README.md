# discord-mbt-docs-bot

A Discord bot that searches the [discord.mbt](https://github.com/gaato/discord.mbt)
guide and posts the matching section as an embed — built with discord.mbt itself.

`/docs <query>` autocompletes over every `##` section of the in-repo guide
(`src/guide/*.mbt.md` in discord.mbt) and replies with the section body and a
link to the rendered page on GitHub.

## Layout

- `src/docs` — the section index and search. `index_generated.mbt` is generated;
  the rest is hand-written.
- `src/gen` — the index generator. It parses the guide chapters by heading and
  emits `src/docs/index_generated.mbt`.
- `src/main` — the native Gateway executable.

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
