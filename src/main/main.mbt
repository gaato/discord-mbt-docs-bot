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
    let app = @app.build(sync=command_sync())
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
