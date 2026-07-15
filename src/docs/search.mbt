///|
/// Rank sections against a query. An empty query lists sections in guide
/// order, which gives autocomplete a sensible default before typing.
pub fn search(
  sections : Array[Section],
  query : String,
  limit? : Int = 25,
) -> Array[Section] {
  let q = query.trim().to_owned().to_lower()
  if q.is_empty() {
    return [..sections[:@cmp.minimum(limit, sections.length())]]
  }
  let scored : Array[(Int, Int, Section)] = []
  for i, section in sections {
    let s = section.score(q)
    if s > 0 {
      scored.push((s, i, section))
    }
  }
  scored.sort_by((a, b) => if a.0 != b.0 { b.0 - a.0 } else { a.1 - b.1 })
  [..scored[:@cmp.minimum(limit, scored.length())].map(entry => entry.2)]
}

///|
pub fn find_by_key(sections : Array[Section], key : String) -> Section? {
  for section in sections {
    if section.key() == key {
      return Some(section)
    }
  }
  None
}

///|
/// Resolve a command argument: an exact key (as produced by autocomplete)
/// wins, otherwise fall back to the best search hit for free-form text.
pub fn resolve(sections : Array[Section], query : String) -> Section? {
  match find_by_key(sections, query) {
    Some(section) => Some(section)
    None => search(sections, query, limit=1).get(0)
  }
}

///|
fn Section::score(self : Section, query : String) -> Int {
  let title = self.title.to_lower()
  let chapter = self.chapter.to_lower()
  if title == query {
    120
  } else if title.has_prefix(query) {
    100
  } else if title.contains(query) {
    80
  } else if chapter.contains(query) {
    60
  } else if self.body.to_lower().contains(query) {
    40
  } else {
    0
  }
}
