///|
/// One-shot command registration for the Worker deployment: builds the
/// same `App` as entry.js and diff-syncs its commands. Run it after
/// `wrangler deploy` (or from CI). Without `DISCORD_GUILD_ID` the
/// commands are registered globally.
fn command_scope() -> @discord.CommandScope {
  match @env.get_env_var("DISCORD_GUILD_ID") {
    Some(raw) =>
      Guild(@model.Id::parse(raw)) catch {
        _ => {
          println("[register] invalid DISCORD_GUILD_ID, syncing globally")
          Global
        }
      }
    None => Global
  }
}

///|
async fn main {
  guard @env.get_env_var("DISCORD_TOKEN") is Some(token) else {
    println("[register] set DISCORD_TOKEN to register commands")
    return
  }
  let scope = command_scope()
  let app = @app.build()
  @async.with_task_group(group => {
    let client = @discord.Client(token)
    group.add_defer(() => client.close())
    let application_id = client.get_current_application().id
    let report = app.sync_commands(client, application_id, scope~)
    println("[register] \{Repr(report)}")
  })
}
