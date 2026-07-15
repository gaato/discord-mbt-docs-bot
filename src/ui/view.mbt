///|
/// Handler prefix for all pagination buttons. The state suffix is
/// `<page>:<section key>`, so a click carries everything needed to
/// rebuild the message: no per-conversation state, any process (or a
/// restarted one) can serve it.
pub let component_prefix : String = "docs:"

///|
pub fn custom_id(section : @docs.Section, page~ : Int) -> String {
  "\{component_prefix}\{page}:\{section.key()}"
}

///|
/// Decode the state suffix of a pagination custom_id. The suffix is
/// untrusted input; anything malformed is rejected with `None`.
pub fn parse_suffix(suffix : String) -> (Int, String)? {
  guard suffix.find(":") is Some(sep) else { return None }
  let page = @string.parse_int(suffix[:sep]) catch { _ => return None }
  Some((page, suffix[sep + 1:].to_owned()))
}

///|
/// The Components V2 layout for one section page.
pub fn view(
  sections : Array[@docs.Section],
  section : @docs.Section,
  page~ : Int,
) -> Array[@model.Component] {
  let pages = section.pages()
  let last = pages.length() - 1
  let page = if page < 0 { 0 } else if page > last { last } else { page }
  let footer = if last > 0 {
    "-# discord.mbt guide · \{page + 1}/\{pages.length()}"
  } else {
    "-# discord.mbt guide"
  }
  let components = [
    @discord.text_display("### [\{section.label()}](\{section.url()})"),
    @discord.text_display(pages[page]),
    @discord.separator(divider=true, spacing=1),
    @discord.text_display(footer),
  ]
  if last > 0 {
    components.push(
      @discord.action_row([
        @discord.button(
          custom_id=custom_id(section, page=page - 1),
          label="◀",
          style=Secondary,
          disabled=page == 0,
        ),
        @discord.button(
          custom_id="\{component_prefix}indicator",
          label="\{page + 1}/\{pages.length()}",
          style=Secondary,
          disabled=true,
        ),
        @discord.button(
          custom_id=custom_id(section, page=page + 1),
          label="▶",
          style=Secondary,
          disabled=page == last,
        ),
      ]),
    )
  }
  let neighbors : Array[@model.Component] = []
  if index_of(sections, section) is Some(i) {
    if i > 0 {
      neighbors.push(
        @discord.button(
          custom_id=custom_id(sections[i - 1], page=0),
          label=button_label("« \{sections[i - 1].label()}"),
          style=Secondary,
        ),
      )
    }
    if i + 1 < sections.length() {
      neighbors.push(
        @discord.button(
          custom_id=custom_id(sections[i + 1], page=0),
          label=button_label("\{sections[i + 1].label()} »"),
          style=Secondary,
        ),
      )
    }
  }
  if !neighbors.is_empty() {
    components.push(@discord.action_row(neighbors))
  }
  [@discord.container(components~, accent_color=0x5865F2)]
}

///|
fn index_of(sections : Array[@docs.Section], section : @docs.Section) -> Int? {
  for i, candidate in sections {
    if candidate.key() == section.key() {
      return Some(i)
    }
  }
  None
}

///|
/// Discord caps button labels at 80 characters.
fn button_label(label : String) -> String {
  if label.length() <= 80 {
    label
  } else {
    "\{label[:79]}…"
  }
}
