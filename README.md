# Loggee

Interact with BGG via a simple CLI.

## Features:

- See your collection
- See your wishlist (only MUST HAVE and LOVE TO HAVE)
- Search for games by name
- See game details by id
- Post plays
- Get a random game from your collection to play

## Configuration, installation and usage

You need Elixir to run the project (developed and tested with Elixir 1.11.2)

For time saving, this project reads the BGG username and password from your
local environment variables. You need to set them wherever you set your envs
(`.bashrc`, `.zshrc`, etc)

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

