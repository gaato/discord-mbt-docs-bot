///|
test "generated API index is populated" {
  assert_true(@api.entries.length() > 1000)
}

///|
test "facade re-exports inherit docs and source links" {
  guard @api.find_by_key(@api.entries, "discord#container") is Some(entry) else {
    fail("missing facade container entry")
  }
  assert_false(entry.doc.is_empty())
  inspect(entry.file, content="src/interaction/builders.mbt")
  assert_true(entry.line > 1)
}

///|
test "generated API keys are unique and fit component state limits" {
  let seen : Map[String, Unit] = Map([])
  for entry in @api.entries {
    let key = entry.key()
    assert_false(seen.contains(key), msg="duplicate key: \{key}")
    seen[key] = ()
    assert_true(key.length() is (1..=90), msg="key out of range: \{key}")
    assert_true(
      entry.label().length() is (1..=100),
      msg="label out of range: \{entry.label()}",
    )
    assert_false(entry.signature.is_empty(), msg="empty signature: \{key}")
  }
}

///|
test "every page of every API entry fits the Components V2 text budget" {
  for entry in @api.entries {
    let pages = entry.pages()
    let title = "### [\{entry.label()}](\{entry.url()})"
    for page, body in pages {
      let footer = if pages.length() > 1 {
        "-# discord.mbt API · @\{entry.pkg} · \{page + 1}/\{pages.length()}"
      } else {
        "-# discord.mbt API · @\{entry.pkg}"
      }
      assert_true(
        title.length() + body.length() + footer.length() <= 4000,
        msg="text displays too long: \{entry.key()} page \{page}",
      )
    }
  }
}
