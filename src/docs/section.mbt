///|
/// One `##` section of a discord.mbt guide chapter, or the chapter intro
/// (the text between the `#` title and the first `##` heading, with an
/// empty `anchor`).
pub(all) struct Section {
  chapter : String
  file : String
  title : String
  anchor : String
  body : String
} derive(Debug, Eq)

///|
/// Stable identifier used as the autocomplete choice value.
pub fn Section::key(self : Section) -> String {
  if self.anchor.is_empty() {
    self.file
  } else {
    "\{self.file}#\{self.anchor}"
  }
}

///|
/// Human-readable label used as the autocomplete choice name.
pub fn Section::label(self : Section) -> String {
  let label = if self.anchor.is_empty() {
    self.chapter
  } else {
    "\{self.chapter} › \{self.title}"
  }
  clip(label, 100)
}

///|
/// Link to the section in the rendered guide on GitHub.
pub fn Section::url(self : Section) -> String {
  let base = "https://github.com/gaato/discord.mbt/blob/main/src/guide/\{self.file}"
  if self.anchor.is_empty() {
    base
  } else {
    "\{base}#\{self.anchor}"
  }
}

///|
fn clip(s : String, limit : Int) -> String {
  if s.length() <= limit {
    s
  } else {
    "\{s[:limit - 1]}…"
  }
}
