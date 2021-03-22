# Loggee

Interact with BGG via a simple CLI.

## Features:

- See your collection
- See your wishlist (only MUST HAVE and LOVE TO HAVE)
- Get a random game from your collection to play
- Search for games by name
- See game details by id
- Post plays
- Get plays by date range
- Get number of plays for each played game by date range, good to keep track of
  your 10x10 challenge.
- NEW: a telegram bot with almost all those features

## Configuration, installation and usage

You need Elixir to run the project (developed and tested with Elixir 1.11.2)

For time saving, this project reads the BGG username and password from your
local environment variables. You need to set them wherever you set your envs
(`.bashrc`, `.zshrc`, etc):

  ```
  export BGG_USERNAME="yourusername"
  export BGG_PASSWORD="yourpassword"
  ```

If you want to run the Telegram bot, create your own following [this
guide](https://core.telegram.org/bots) and set the token in your env vars

```
  export TELEGRAM_LOGEE_TOKEN="yourtoken"
```


To install the project, just clone it and generate the executable:

  ```
  git clone git@github.com:gionaufal/loggee.git
  cd loggee
  mix deps.get
  mix escript.build
  ./loggee
  ```

## TO DO:

- Implement post plays into the telegram bot
- Implement a web UI
- General CLI UI improvements
