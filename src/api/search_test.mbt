///|
fn api_entry(pkg : String, name : String, doc? : String = "") -> @api.ApiEntry {
  {
    pkg,
    name,
    kind: "fn",
    signature: "pub fn \{name}() -> Unit",
    doc,
    file: "src/model/example.mbt",
    line: 10,
  }
}

///|
test "exact, prefix, and contains name matches rank in that order" {
  let entries = [
    api_entry("gaato/discord/model", "NewWidget"),
    api_entry("gaato/discord/model", "WidgetBuilder"),
    api_entry("gaato/discord/model", "Widget"),
    api_entry("gaato/discord/model", "Other", doc="mentions widget"),
  ]
  json_inspect(@api.search(entries, "widget").map(e => e.name), content=[
    "Widget", "WidgetBuilder", "NewWidget", "Other",
  ])
}

///|
test "facade package wins score ties before generated index order" {
  let entries = [
    api_entry("gaato/discord/model", "Widget"),
    api_entry("gaato/discord", "Widget"),
  ]
  json_inspect(@api.search(entries, "widget").map(e => e.pkg), content=[
    "gaato/discord", "gaato/discord/model",
  ])
}

///|
test "find_by_key and resolve use alias keys with search fallback" {
  let entries = [
    api_entry("gaato/discord", "Widget"),
    api_entry("gaato/discord/model", "AllowedMentions::none"),
  ]
  inspect(entries[0].key(), content="discord#Widget")
  inspect(entries[1].key(), content="model#AllowedMentions::none")
  inspect(entries[1].label(), content="@model.AllowedMentions::none")
  guard @api.find_by_key(entries, "model#AllowedMentions::none") is Some(found) else {
    fail("expected alias key match")
  }
  assert_eq(found.name, "AllowedMentions::none")
  guard @api.resolve(entries, "model#AllowedMentions::none") is Some(by_key) else {
    fail("expected resolve by key")
  }
  assert_eq(by_key.name, "AllowedMentions::none")
  guard @api.resolve(entries, "allow") is Some(by_search) else {
    fail("expected resolve search fallback")
  }
  assert_eq(by_search.name, "AllowedMentions::none")
  assert_true(@api.resolve(entries, "missing") is None)
}
