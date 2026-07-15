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
test "multi-page section renders the ordered V2 tree with both button rows" {
  let sections = fixture()
  let rendered = @ui.view(sections, sections[1], page=0)
  guard rendered is [Container(container)] else {
    fail("expected one container")
  }
  guard container.accent_color is Some(Value(0x5865F2)) else {
    fail("expected blurple container accent")
  }
  guard container.components
    is [
      TextDisplay(title),
      TextDisplay(body),
      Separator(_),
      TextDisplay(footer),
      ActionRow(_),
      ActionRow(_),
    ] else {
    fail("unexpected container children")
  }
  inspect(
    title.content,
    content="### [Two › Long](https://github.com/gaato/discord.mbt/blob/main/src/guide/02-two.mbt.md#long)",
  )
  assert_eq(body.content, sections[1].pages()[0])
  inspect(footer.content, content="-# discord.mbt guide · 1/2")
  json_inspect(container.components[2], content={
    "divider": true,
    "spacing": 1,
    "type": 14,
  })
  json_inspect(container.components[4], content={
    "components": [
      {
        "style": 2,
        "label": "◀",
        "custom_id": "docs:-1:02-two.mbt.md#long",
        "disabled": true,
        "type": 2,
      },
      {
        "style": 2,
        "label": "1/2",
        "custom_id": "docs:indicator",
        "disabled": true,
        "type": 2,
      },
      {
        "style": 2,
        "label": "▶",
        "custom_id": "docs:1:02-two.mbt.md#long",
        "disabled": false,
        "type": 2,
      },
    ],
    "type": 1,
  })
  json_inspect(container.components[5], content={
    "components": [
      {
        "style": 2,
        "label": "« One",
        "custom_id": "docs:0:01-one.mbt.md",
        "type": 2,
      },
      {
        "style": 2,
        "label": "Three »",
        "custom_id": "docs:0:03-three.mbt.md",
        "type": 2,
      },
    ],
    "type": 1,
  })
}

///|
test "single-page section omits the pager and empty neighbor row" {
  let sections = fixture()
  let with_neighbor = @ui.view(sections, sections[0], page=0)
  guard with_neighbor is [Container(container)] else {
    fail("expected one container")
  }
  guard container.components
    is [
      TextDisplay(_),
      TextDisplay(_),
      Separator(_),
      TextDisplay(footer),
      ActionRow(_),
    ] else {
    fail("expected footer followed by one neighbor row")
  }
  inspect(footer.content, content="-# discord.mbt guide")
  let alone = @ui.view([sections[0]], sections[0], page=0)
  guard alone is [Container(alone_container)] else {
    fail("expected one container")
  }
  inspect(alone_container.components.length(), content="4")
}

///|
test "out-of-range pages clamp instead of failing" {
  let sections = fixture()
  let pages = sections[1].pages()
  let last = @ui.view(sections, sections[1], page=999)
  let first = @ui.view(sections, sections[1], page=-5)
  guard last is [Container(last_container)] else {
    fail("expected one container")
  }
  guard first is [Container(first_container)] else {
    fail("expected one container")
  }
  guard last_container.components
    is [_, TextDisplay(last_body), _, TextDisplay(last_footer), ActionRow(_), _] else {
    fail("unexpected last-page tree")
  }
  guard first_container.components
    is [
      _,
      TextDisplay(first_body),
      _,
      TextDisplay(first_footer),
      ActionRow(_),
      _,
    ] else {
    fail("unexpected first-page tree")
  }
  assert_eq(last_body.content, pages[pages.length() - 1])
  assert_eq(first_body.content, pages[0])
  inspect(last_footer.content, content="-# discord.mbt guide · 2/2")
  inspect(first_footer.content, content="-# discord.mbt guide · 1/2")
  json_inspect(last_container.components[4], content={
    "components": [
      {
        "style": 2,
        "label": "◀",
        "custom_id": "docs:0:02-two.mbt.md#long",
        "disabled": false,
        "type": 2,
      },
      {
        "style": 2,
        "label": "2/2",
        "custom_id": "docs:indicator",
        "disabled": true,
        "type": 2,
      },
      {
        "style": 2,
        "label": "▶",
        "custom_id": "docs:2:02-two.mbt.md#long",
        "disabled": true,
        "type": 2,
      },
    ],
    "type": 1,
  })
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
