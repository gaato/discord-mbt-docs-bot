///|
fn command_scope() -> @discord.CommandScope raise {
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
    let bot = @discord.Bot(@app.build(), token~, sync=command_scope())
    bot.on(@discord.Events::ready(), (_, ready) => {
      println(
        "ready as \{ready.user.username} (\{@docs.sections.length()} sections indexed)",
      )
    })
    bot.run()
  } catch {
    _ if @async.is_being_cancelled() => ()
    error => raise error
  }
  println("[bot] shutting down")
}
