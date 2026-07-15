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
test "every page of every section renders a bounded embed" {
  for section in @docs.sections {
    for page in 0..<section.pages().length() {
      let embed = section.to_embed(page~)
      guard embed.description is Some(description) else {
        fail("missing description: \{section.key()} page \{page}")
      }
      assert_true(
        description.length() <= 4096,
        msg="description too long: \{section.key()} page \{page}",
      )
    }
  }
}
