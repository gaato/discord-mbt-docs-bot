///|
let fixture : Array[@docs.Section] = [
  {
    chapter: "Getting started",
    file: "01-getting-started.mbt.md",
    title: "Getting started",
    anchor: "",
    body: "This guide creates a native Gateway bot.",
  },
  {
    chapter: "Getting started",
    file: "01-getting-started.mbt.md",
    title: "Install",
    anchor: "install",
    body: "moon add gaato/discord",
  },
  {
    chapter: "Commands",
    file: "02-commands.mbt.md",
    title: "Autocomplete",
    anchor: "autocomplete",
    body: "Attach autocomplete to the argument that owns it.",
  },
]

///|
test "empty query lists sections in guide order" {
  let hits = @docs.search(fixture, "", limit=2)
  json_inspect(hits.map(s => s.key()), content=[
    "01-getting-started.mbt.md", "01-getting-started.mbt.md#install",
  ])
}

///|
test "title match outranks body match" {
  let hits = @docs.search(fixture, "install")
  json_inspect(hits.map(s => s.key()), content=[
    "01-getting-started.mbt.md#install",
  ])
  let body_hits = @docs.search(fixture, "gateway bot")
  json_inspect(body_hits.map(s => s.key()), content=[
    "01-getting-started.mbt.md",
  ])
}

///|
test "resolve prefers exact keys and falls back to search" {
  let by_key = @docs.resolve(fixture, "02-commands.mbt.md#autocomplete")
  json_inspect(by_key.map(s => s.title), content=["Autocomplete"])
  let by_text = @docs.resolve(fixture, "autocomp")
  json_inspect(by_text.map(s => s.title), content=["Autocomplete"])
  assert_true(@docs.resolve(fixture, "no such thing") is None)
}

///|
test "labels and urls" {
  inspect(fixture[0].label(), content="Getting started")
  inspect(fixture[2].label(), content="Commands › Autocomplete")
  inspect(
    fixture[2].url(),
    content="https://github.com/gaato/discord.mbt/blob/main/src/guide/02-commands.mbt.md#autocomplete",
  )
}
