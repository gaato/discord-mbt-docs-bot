///|
fn api_fixture(doc : String) -> @api.ApiEntry {
  {
    pkg: "gaato/discord/model",
    name: "Widget::find",
    kind: "fn",
    signature: "pub fn Widget::find(String) -> Widget?",
    doc,
    file: "src/model/widget.mbt",
    line: 42,
  }
}

///|
test "single-page API symbol renders ordered V2 children without a pager" {
  let entry = api_fixture("Find a widget by name.")
  let rendered = @ui.api_view(entry, page=0)
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
    ] else {
    fail("unexpected container children")
  }
  inspect(
    title.content,
    content="### [@model.Widget::find](https://github.com/gaato/discord.mbt/blob/main/src/model/widget.mbt#L42)",
  )
  assert_eq(body.content, entry.pages()[0])
  inspect(footer.content, content="-# discord.mbt API · @gaato/discord/model")
  json_inspect(container.components[2], content={
    "divider": true,
    "spacing": 1,
    "type": 14,
  })
}

///|
test "multi-page API symbol adds only the pager action row" {
  let entry = api_fixture(
    Array::makei(240, i => "documentation line \{i}").join("\n"),
  )
  let pages = entry.pages()
  assert_true(pages.length() > 1)
  let rendered = @ui.api_view(entry, page=0)
  guard rendered is [Container(container)] else {
    fail("expected one container")
  }
  guard container.components
    is [
      TextDisplay(_),
      TextDisplay(body),
      Separator(_),
      TextDisplay(footer),
      ActionRow(_),
    ] else {
    fail("unexpected container children")
  }
  assert_eq(body.content, pages[0])
  inspect(
    footer.content,
    content="-# discord.mbt API · @gaato/discord/model · 1/4",
  )
  json_inspect(container.components[4], content={
    "components": [
      {
        "style": 2,
        "label": "◀",
        "custom_id": "api:-1:model#Widget::find",
        "disabled": true,
        "type": 2,
      },
      {
        "style": 2,
        "label": "1/4",
        "custom_id": "api:indicator",
        "disabled": true,
        "type": 2,
      },
      {
        "style": 2,
        "label": "▶",
        "custom_id": "api:1:model#Widget::find",
        "disabled": false,
        "type": 2,
      },
    ],
    "type": 1,
  })
}

///|
test "out-of-range API pages clamp" {
  let entry = api_fixture(
    Array::makei(240, i => "documentation line \{i}").join("\n"),
  )
  let pages = entry.pages()
  let rendered = @ui.api_view(entry, page=999)
  guard rendered is [Container(container)] else {
    fail("expected one container")
  }
  guard container.components
    is [_, TextDisplay(body), _, TextDisplay(footer), ActionRow(_)] else {
    fail("unexpected container children")
  }
  assert_eq(body.content, pages[pages.length() - 1])
  inspect(
    footer.content,
    content="-# discord.mbt API · @gaato/discord/model · 4/4",
  )
}
