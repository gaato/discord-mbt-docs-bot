///|
test "pages close and reopen code fences at page breaks" {
  let section : @docs.Section = {
    chapter: "C",
    file: "f.mbt.md",
    title: "T",
    anchor: "t",
    body: ["intro", "```mbt", "a", "b", "c", "```", "outro"].join("\n"),
  }
  json_inspect(section.pages(page_chars=16), content=[
    "intro\n```mbt\na\n```", "```mbt\nb\nc\n```", "outro",
  ])
}

///|
test "short bodies stay on one page" {
  let section : @docs.Section = {
    chapter: "C",
    file: "f.mbt.md",
    title: "T",
    anchor: "",
    body: "one line",
  }
  json_inspect(section.pages(), content=["one line"])
}
