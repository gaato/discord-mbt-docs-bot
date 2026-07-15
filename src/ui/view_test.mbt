///|
fn fixture() -> Array[@docs.Section] {
  [
    {
      chapter: "One",
      file: "01-one.mbt.md",
      title: "One",
      anchor: "",
      body: "short",
    },
    {
      chapter: "Two",
      file: "02-two.mbt.md",
      title: "Long",
      anchor: "long",
      body: Array::makei(200, i => "line \{i}").join("\n"),
    },
    {
      chapter: "Three",
      file: "03-three.mbt.md",
      title: "Three",
      anchor: "",
      body: "also short",
    },
  ]
}

///|
test "suffix roundtrip and malformed input" {
  let sections = fixture()
  let id = @ui.custom_id(sections[1], page=3)
  inspect(id, content="docs:3:02-two.mbt.md#long")
  let suffix = id["docs:".length():].to_owned()
  debug_inspect(
    @ui.parse_suffix(suffix),
    content=(
      #|Some((3, "02-two.mbt.md#long"))
    ),
  )
  assert_true(@ui.parse_suffix("indicator") is None)
  assert_true(@ui.parse_suffix(":missing-page") is None)
  assert_true(@ui.parse_suffix("") is None)
}

///|
test "multi-page section gets a pager row, single-page does not" {
  let sections = fixture()
  let (embeds, with_pager) = @ui.view(sections, sections[1], page=0)
  inspect(embeds.length(), content="1")
  inspect(with_pager.length(), content="2")
  let (_, without_pager) = @ui.view(sections, sections[0], page=0)
  inspect(without_pager.length(), content="1")
  let (_, alone) = @ui.view([sections[0]], sections[0], page=0)
  inspect(alone.length(), content="0")
}

///|
test "out-of-range pages clamp instead of failing" {
  let sections = fixture()
  let (embeds, _) = @ui.view(sections, sections[1], page=999)
  let (first, _) = @ui.view(sections, sections[1], page=-5)
  guard embeds[0].footer is Some(footer)
  guard first[0].footer is Some(first_footer)
  assert_true(footer.text.has_suffix("/2"))
  assert_true(first_footer.text.has_suffix("1/2"))
}

///|
test "every generated custom_id fits Discord's 100-char limit" {
  for section in @docs.sections {
    assert_true(
      @ui.custom_id(section, page=99).length() <= 100,
      msg="custom_id too long: \{section.key()}",
    )
  }
}
