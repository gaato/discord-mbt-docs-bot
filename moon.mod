name = "gaato/discord-mbt-docs-bot"

version = "0.1.0"

license = "BlueOak-1.0.0"

source = "src"

preferred_target = "native"

// Trait methods are never promoted to regular methods implicitly.

warnings = "-implicit_impl_as_method"

import {
  "gaato/discord@0.4.1",
  "moonbitlang/async@0.22.1",
}
