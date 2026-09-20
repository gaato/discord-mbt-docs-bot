///|
/// The bot's single `App` definition, shared by the native Gateway
/// executable, the Cloudflare Worker, and the one-shot command
/// registration — so the deployed handlers and the registered commands
/// cannot drift. Registration is the executor's or the one-shot's business.
pub fn build() -> @discord.App {
  let app = @discord.App()
  @ui.register(app, @docs.sections, @api.entries)
  app
}
