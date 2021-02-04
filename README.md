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
  your 10x10 challenge (WIP, currently has a bug because it's only counting the
last 100 plays)

## Configuration, installation and usage

You need Elixir to run the project (developed and tested with Elixir 1.11.2)

For time saving, this project reads the BGG username and password from your
local environment variables. You need to set them wherever you set your envs
(`.bashrc`, `.zshrc`, etc):

  ```
  export BGG_USERNAME="yourusername"
  export BGG_PASSWORD="yourpassword"
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

- Implement a telegram bot
- Implement a web UI
- General CLI UI improvements
