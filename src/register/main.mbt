///|
/// One-shot command registration for the Worker deployment: builds the
/// same `App` as entry.js and diff-syncs its commands. Run it after
/// `wrangler deploy` (or from CI). Without `DISCORD_GUILD_ID` the
/// commands are registered globally.
fn command_sync() -> @discord.CommandSync {
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
  let sync = command_sync()
  let app = @app.build(sync~)
  @async.with_task_group(group => {
    let client = @discord.Client(token)
    group.add_defer(() => client.close())
    let application_id = client.get_current_application().id
    app.sync_commands(client, application_id)
    println("[register] commands synced (\{to_repr(sync)})")
  })
}
