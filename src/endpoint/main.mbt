///|
fn endpoint_url(application : @model.Application) -> String {
  guard application.interactions_endpoint_url is Some(value) else {
    return "(not set)"
  }
  value.to_option().unwrap_or("(not set)")
}

///|
fn print_status(application : @model.Application) -> Unit {
  println("application id: \{application.id}")
  println("name: \{application.name}")
  println("interactions_endpoint_url: \{endpoint_url(application)}")
  println("verify_key: \{application.verify_key.unwrap_or("(not set)")}")
}

///|
fn print_usage() -> Unit {
  println(
    "Usage: moon run --target native --release src/endpoint -- [status | set <url> | clear]",
  )
}

///|
async fn main {
  guard @env.get_env_var("DISCORD_TOKEN") is Some(token) else {
    println("[endpoint] set DISCORD_TOKEN to manage the interactions endpoint")
    return
  }
  let argv = @env.args()
  @async.with_task_group(group => {
    let client = @discord.Client(token)
    group.add_defer(() => client.close())
    match (argv.get(1), argv.length()) {
      (None, 1) | (Some("status"), 2) =>
        print_status(client.get_current_application())
      (Some("set"), 3) => {
        let url = argv[2]
        println(
          "[endpoint] Discord sends a PING to verify this URL; deploy the Worker before setting it",
        )
        println(
          "[endpoint] while an endpoint is configured, interactions are not delivered to Gateway (src/main)",
        )
        let application = client.edit_current_application(
          interactions_endpoint_url=url,
        )
        println(
          "[endpoint] interactions_endpoint_url: \{endpoint_url(application)}",
        )
      }
      (Some("clear"), 2) => {
        client.edit_current_application(clear_interactions_endpoint_url=true)
        |> ignore
        println(
          "[endpoint] interactions endpoint cleared; interactions are delivered to Gateway (src/main) again",
        )
      }
      _ => print_usage()
    }
  })
}
