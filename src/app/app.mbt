///|
/// The bot's single `App` definition, shared by the native Gateway
/// executable, the Cloudflare Worker, and the one-shot command
/// registration — so the deployed handlers and the registered commands
/// cannot drift.
pub fn build(sync? : @discord.CommandSync = Disabled) -> @discord.App {
  let app = @discord.App(sync~)
  @ui.register(app, @docs.sections)
  app
}
