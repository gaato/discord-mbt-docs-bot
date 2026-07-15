///|
/// Split the body into self-contained pages at an approximate character budget.
/// Pages break at line boundaries. A page that would cut a fenced code
/// block closes the fence, and the next page reopens it with the same
/// info string, so every page renders as valid markdown on its own.
pub fn Section::pages(
  self : Section,
  page_chars? : Int = 1400,
) -> Array[String] {
  if self.body.length() <= page_chars {
    return [self.body]
  }
  let pages : Array[String] = []
  let current : Array[String] = []
  let mut len = 0
  let mut fence : String? = None
  for line in self.body.split("\n") {
    let line = line.to_owned()
    if len + line.length() + 1 > page_chars && !current.is_empty() {
      if fence is Some(_) {
        current.push("```")
      }
      pages.push(current.join("\n"))
      current.clear()
      len = 0
      if fence is Some(info) {
        current.push("```\{info}")
        len = info.length() + 4
      }
    }
    let trimmed = line.trim().to_owned()
    if trimmed.has_prefix("```") {
      fence = match fence {
        Some(_) => None
        None => Some(trimmed["```".length():].to_owned())
      }
    }
    current.push(line)
    len += line.length() + 1
  }
  if !current.is_empty() {
    pages.push(current.join("\n"))
  }
  if pages.is_empty() {
    [""]
  } else {
    pages
  }
}
