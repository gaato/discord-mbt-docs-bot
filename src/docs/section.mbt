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
pub fn Section::to_embed(self : Section, page? : Int = 0) -> @model.Embed {
  let pages = self.pages()
  let page = if page < 0 {
    0
  } else if page >= pages.length() {
    pages.length() - 1
  } else {
    page
  }
  let footer = if pages.length() > 1 {
    "discord.mbt guide · \{page + 1}/\{pages.length()}"
  } else {
    "discord.mbt guide"
  }
  {
    title: Some(self.label()),
    typ: None,
    url: Some(self.url()),
    description: Some(pages[page]),
    timestamp: None,
    color: Some(0x5865F2),
    footer: Some({ text: footer, icon_url: None, proxy_icon_url: None }),
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
