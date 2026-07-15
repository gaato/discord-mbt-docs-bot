///|
fn docs_command() -> @discord.Command[String] {
  @discord.slash(
    name="docs",
    description="Search the discord.mbt guide",
    args=@discord.Args::of(
      @discord.arg_string(
        name="query",
        description="Guide section to look up",
        suggest=(_, input) => {
          @docs.search(@docs.sections, input).map(section => {
            @discord.string_choice(section.label(), section.key())
          })
        },
      ),
    ),
    handler=Immediate((_, query) => {
      match @docs.resolve(@docs.sections, query) {
        Some(section) =>
          @discord.CommandReply::message(embeds=[section.to_embed()])
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
fn command_sync() -> @discord.CommandSync raise {
  match @env.get_env_var("DISCORD_GUILD_ID") {
    Some(id) => Guild(@model.Id::parse(id))
    None => Global
  }
}

///|
async fn main {
  @signal.set_global_cancellation_signals([SIGINT, SIGTERM])
  try {
    guard @env.get_env_var("DISCORD_TOKEN") is Some(token) else {
      println("DISCORD_TOKEN is not set")
      return
    }
    let app = @discord.App(sync=command_sync())
    app.command(docs_command())
    let bot = @discord.Bot(app, token~)
    bot.on(@discord.Events::ready(), (_, ready) => {
      println(
        "ready as \{ready.user.username} (\{@docs.sections.length()} sections indexed)",
      )
    })
    bot.run()
  } catch {
    error if @async.is_being_cancelled() || @async.is_cancellation_error(error) =>
      ()
    error => raise error
  }
  println("[bot] shutting down")
}
