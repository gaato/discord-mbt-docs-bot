///|
/// Register the `/docs` command and the pagination component handler.
pub fn register(app : @discord.App, sections : Array[@docs.Section]) -> Unit {
  app.command(docs_command(sections))
  app.on_component(
    prefix=component_prefix,
    Immediate(ctx => {
      match parse_suffix(ctx.suffix()) {
        Some((page, key)) =>
          match @docs.find_by_key(sections, key) {
            Some(section) => {
              let components = view(sections, section, page~)
              @discord.ComponentReply::update_message(embeds=[], components~)
            }
            None => stale_reply()
          }
        None => stale_reply()
      }
    }),
  )
}

///|
fn docs_command(sections : Array[@docs.Section]) -> @discord.Command[String] {
  @discord.slash(
    name="docs",
    description="Search the discord.mbt guide",
    args=@discord.Args::of(
      @discord.arg_string(
        name="query",
        description="Guide section to look up",
        suggest=(_, input) => {
          @docs.search(sections, input).map(section => {
            @discord.string_choice(section.label(), section.key())
          })
        },
      ),
    ),
    handler=Immediate((_, query) => {
      match @docs.resolve(sections, query) {
        Some(section) => {
          let components = view(sections, section, page=0)
          @discord.CommandReply::message(components~)
        }
        None =>
          @discord.CommandReply::message(
            content="No guide section matches “\{query}”.",
            ephemeral=true,
          )
      }
    }),
  )
}

///|
/// A clicked button can outlive the index it was rendered from (the guide
/// section was renamed or removed since). Tell the user instead of failing.
fn stale_reply() -> @discord.ComponentReply {
  @discord.ComponentReply::message(
    content="This button refers to a guide section that no longer exists. Run /docs again.",
    ephemeral=true,
  )
}
