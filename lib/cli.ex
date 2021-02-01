defmodule Loggee.Cli do
  @user System.get_env("BGG_USERNAME")
  @options [
    random_game: "Get a random game from my collection",
    post_play: "Post a played game",
    plays: "See my plays",
    play_count: "Play count for your played games in a given interval",
    search: "Search for a game",
    game: "See game details searching by ID",
    wishlist: "See my wishlist",
    collection: "See my collection"
  ]

  def main(_args) do
    IO.puts("Welcome to Loggee!\n")
    IO.puts("What do you want to do?\n")

    @options
    |> Enum.with_index
    |> Enum.each(fn {{_k, value}, index} ->
      IO.puts("[#{index}] - #{value}")
    end)

    option = Enum.at(@options, IO.gets("-> ")
             |> String.trim
             |> String.to_integer)
             |> elem(0)

    result = case option do
      :collection -> Loggee.collection(@user, :collection)
      :wishlist -> Loggee.collection(@user, :wishlist)
      :game -> Loggee.game(IO.gets("what is the game id?\n-> ") |> String.trim)
      :plays -> Loggee.plays(@user,
        IO.gets("starting when? YYYY-MM-DD\n-> ") |> String.trim,
        IO.gets("ending when? YYYY-MM-DD\n-> ") |> String.trim
      )
      :play_count -> Loggee.play_count(@user,
        IO.gets("starting when? YYYY-MM-DD\n-> ") |> String.trim,
        IO.gets("ending when? YYYY-MM-DD\n-> ") |> String.trim
      )
      :search -> Loggee.search(IO.gets("what is the game name?\n-> ") |> String.trim)
      _ -> apply(Loggee, option, [])
    end

    IO.inspect(result)
  end
end
