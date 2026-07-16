///|
/// One public discord.mbt declaration and its source documentation.
pub(all) struct ApiEntry {
  pkg : String
  name : String
  kind : String
  signature : String
  doc : String
  file : String
  line : Int
} derive(Debug, Eq)

///|
/// Stable identifier used as the autocomplete value and component state.
pub fn ApiEntry::key(self : ApiEntry) -> String {
  "\{package_alias(self.pkg)}#\{self.name}"
}

///|
/// MoonBit-style package alias and symbol name shown in autocomplete.
pub fn ApiEntry::label(self : ApiEntry) -> String {
  clip("@\{package_alias(self.pkg)}.\{self.name}", 100)
}

///|
fn package_alias(pkg : String) -> String {
  if pkg == "gaato/discord" {
    "discord"
  } else {
    let mut short_name = pkg
    for segment in pkg.split("/") {
      short_name = segment.to_owned()
    }
    short_name
  }
}

///|
/// Link to the declaration in the discord.mbt source tree.
pub fn ApiEntry::url(self : ApiEntry) -> String {
  "https://github.com/gaato/discord.mbt/blob/main/\{self.file}#L\{self.line}"
}

///|
/// Render the signature and docs as self-contained Markdown pages.
pub fn ApiEntry::pages(self : ApiEntry) -> Array[String] {
  let body = if self.doc.is_empty() {
    "```mbt\n\{self.signature}\n```"
  } else {
    "```mbt\n\{self.signature}\n```\n\n\{self.doc}"
  }
  @docs.paginate(body)
}

///|
fn clip(s : String, limit : Int) -> String {
  if s.length() <= limit {
    s
  } else {
    "\{s[:limit - 1]}…"
  }
}
