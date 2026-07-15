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
pub fn Section::to_embed(self : Section) -> @model.Embed {
  {
    title: Some(self.label()),
    typ: None,
    url: Some(self.url()),
    description: Some(clip_at_line(self.body, 1400)),
    timestamp: None,
    color: Some(0x5865F2),
    footer: Some({
      text: "discord.mbt guide",
      icon_url: None,
      proxy_icon_url: None,
    }),
    image: None,
    thumbnail: None,
    video: None,
    provider: None,
    author: None,
    fields: None,
    flags: None,
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

///|
/// Truncate at the last line boundary that fits, so code fences and
/// markdown structure are never cut mid-line.
fn clip_at_line(s : String, limit : Int) -> String {
  if s.length() <= limit {
    return s
  }
  let head = s[:limit]
  let cut = match head.rev_find("\n") {
    Some(pos) => s[:pos]
    None => head
  }
  "\{cut}\n…"
}
