///|
/// Register the `/docs` and `/api` commands and their component handlers.
pub fn register(
  app : @discord.App,
  sections : Array[@docs.Section],
  entries : Array[@api.ApiEntry],
) -> Unit {
  app.command(docs_command(sections))
  app.command(api_command(entries))
  app.on_component(
    docs_route,
    Immediate((_, state) => {
      let (page, key) = state
      match @docs.find_by_key(sections, key) {
        Some(section) => {
          let components = view(sections, section, page~)
          @discord.ComponentReply::update_message(embeds=[], components~)
        }
        None => docs_stale_reply()
      }
    }),
  )
  app.on_component(
    api_route,
    Immediate((_, state) => {
      let (page, key) = state
      match @api.find_by_key(entries, key) {
        Some(entry) => {
          let components = api_view(entry, page~)
          @discord.ComponentReply::update_message(embeds=[], components~)
        }
        None => api_stale_reply()
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
fn api_command(entries : Array[@api.ApiEntry]) -> @discord.Command[String] {
  @discord.slash(
    name="api",
    description="Look up discord.mbt API documentation",
    args=@discord.Args::of(
      @discord.arg_string(name="symbol", description="API symbol to look up", suggest=(
        _,
        input,
      ) => {
        @api.search(entries, input).map(entry => {
          @discord.string_choice(entry.label(), entry.key())
        })
      }),
    ),
    handler=Immediate((_, query) => {
      match @api.resolve(entries, query) {
        Some(entry) => {
          let components = api_view(entry, page=0)
          @discord.CommandReply::message(components~)
        }
        None =>
          @discord.CommandReply::message(
            content="No API symbol matches “\{query}”.",
            ephemeral=true,
          )
      }
    }),
  )
}

///|
/// A clicked button can outlive the index it was rendered from (the guide
/// section was renamed or removed since). Tell the user instead of failing.
fn docs_stale_reply() -> @discord.ComponentReply {
  @discord.ComponentReply::message(
    content="This button refers to a guide section that no longer exists. Run /docs again.",
    ephemeral=true,
  )
}

///|
fn api_stale_reply() -> @discord.ComponentReply {
  @discord.ComponentReply::message(
    content="This button refers to an API symbol that no longer exists. Run /api again.",
    ephemeral=true,
  )
}
