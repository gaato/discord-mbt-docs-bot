///|
/// Rank API symbols against a query. Empty input preserves generated index
/// order, which provides deterministic autocomplete before typing.
pub fn search(
  entries : Array[ApiEntry],
  query : String,
  limit? : Int = 25,
) -> Array[ApiEntry] {
  let q = query.trim().to_owned().to_lower()
  if q.is_empty() {
    return [..entries[:@cmp.minimum(limit, entries.length())]]
  }
  let scored : Array[(Int, Int, Int, ApiEntry)] = []
  for i, entry in entries {
    let score = entry.score(q)
    if score > 0 {
      scored.push((score, entry.pkg.length(), i, entry))
    }
  }
  scored.sort_by((a, b) => {
    if a.0 != b.0 {
      b.0 - a.0
    } else if a.1 != b.1 {
      a.1 - b.1
    } else {
      a.2 - b.2
    }
  })
  [..scored[:@cmp.minimum(limit, scored.length())].map(item => item.3)]
}

///|
pub fn find_by_key(entries : Array[ApiEntry], key : String) -> ApiEntry? {
  for entry in entries {
    if entry.key() == key {
      return Some(entry)
    }
  }
  None
}

///|
/// Resolve an autocomplete key first, then fall back to free-form search.
pub fn resolve(entries : Array[ApiEntry], query : String) -> ApiEntry? {
  match find_by_key(entries, query) {
    Some(entry) => Some(entry)
    None => search(entries, query, limit=1).get(0)
  }
}

///|
fn ApiEntry::score(self : ApiEntry, query : String) -> Int {
  let name = self.name.to_lower()
  if name == query {
    120
  } else if name.has_prefix(query) {
    100
  } else if name.contains(query) {
    80
  } else if self.doc.to_lower().contains(query) {
    40
  } else {
    0
  }
}
