///|
/// Handler prefix for symbol API pagination buttons.
pub let api_component_prefix : String = "api:"

///|
fn api_custom_id(entry : @api.ApiEntry, page~ : Int) -> String {
  "\{api_component_prefix}\{page}:\{entry.key()}"
}

///|
/// The Components V2 layout for one API symbol page.
pub fn api_view(entry : @api.ApiEntry, page~ : Int) -> Array[@model.Component] {
  let pages = entry.pages()
  let last = pages.length() - 1
  let page = if page < 0 { 0 } else if page > last { last } else { page }
  let footer = if last > 0 {
    "-# discord.mbt API · @\{entry.pkg} · \{page + 1}/\{pages.length()}"
  } else {
    "-# discord.mbt API · @\{entry.pkg}"
  }
  let components = [
    @discord.text_display("### [\{entry.label()}](\{entry.url()})"),
    @discord.text_display(pages[page]),
    @discord.separator(divider=true, spacing=1),
    @discord.text_display(footer),
  ]
  if last > 0 {
    components.push(
      @discord.action_row([
        @discord.button(
          custom_id=api_custom_id(entry, page=page - 1),
          label="◀",
          style=Secondary,
          disabled=page == 0,
        ),
        @discord.button(
          custom_id="\{api_component_prefix}indicator",
          label="\{page + 1}/\{pages.length()}",
          style=Secondary,
          disabled=true,
        ),
        @discord.button(
          custom_id=api_custom_id(entry, page=page + 1),
          label="▶",
          style=Secondary,
          disabled=page == last,
        ),
      ]),
    )
  }
  [@discord.container(components~, accent_color=0x5865F2)]
}
