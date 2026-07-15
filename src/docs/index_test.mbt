///|
test "generated index is populated and starts at chapter 1" {
  assert_true(@docs.sections.length() > 30)
  inspect(@docs.sections[0].file, content="01-getting-started.mbt.md")
}

///|
test "generated keys are unique and fit Discord choice limits" {
  let seen : Map[String, Unit] = Map([])
  for section in @docs.sections {
    let key = section.key()
    assert_false(seen.contains(key), msg="duplicate key: \{key}")
    seen[key] = ()
    assert_true(key.length() is (1..=100), msg="key out of range: \{key}")
    assert_true(
      section.label().length() is (1..=100),
      msg="label out of range: \{section.label()}",
    )
  }
}

///|
test "every page of every section fits the Components V2 text budget" {
  for section in @docs.sections {
    let pages = section.pages()
    let title = "### [\{section.label()}](\{section.url()})"
    for page, body in pages {
      let footer = if pages.length() > 1 {
        "-# discord.mbt guide · \{page + 1}/\{pages.length()}"
      } else {
        "-# discord.mbt guide"
      }
      assert_true(
        title.length() + body.length() + footer.length() <= 4000,
        msg="text displays too long: \{section.key()} page \{page}",
      )
    }
  }
}
