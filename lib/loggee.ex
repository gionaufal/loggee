defmodule Loggee do
  alias Loggee.Bgg.Client.{Collection, Game, Plays, Search}
  alias Loggee.Commands

  @user System.get_env("BGG_USERNAME")
  @options [
      random_game: "Get a random game from my collection",
      post_play: "Post a played game",
      plays: "See my plays",
      search: "Search for a game",
      game: "See game details searching by ID",
      wishlist: "See my wishlist",
      collection: "See my collection"
    ]


  defdelegate collection(user, collection), to: Collection, as: :call
  defdelegate game(id), to: Game, as: :call
  defdelegate plays(user, start_date \\ nil, end_date \\ nil, id \\ nil), to: Plays, as: :call
  defdelegate search(query), to: Search, as: :call
  defdelegate post_play(), to: Commands.PostPlay, as: :call
  defdelegate random_game(), to: Commands.RandomGame, as: :call

  def start() do
    IO.puts("Welcome to Loggee!\n")
    IO.puts("What do you want to do?\n")

    @options
    |> Enum.with_index
    |> Enum.each(fn {{_k, value}, index} ->
      IO.puts("[#{index}] - #{value}")
    end)

    option = Enum.at(@options, IO.gets("->")
             |> String.trim
             |> String.to_integer)
             |> elem(0)

    case option do
      :collection -> collection(@user, "collection")
      :wishlist -> collection(@user, "wishlist")
      :game -> game(IO.gets("what is the game id?\n") |> String.trim)
      :plays -> plays(@user,
          IO.gets("starting when? YYYY-MM-DD\n") |> String.trim,
          IO.gets("ending when? YYYY-MM-DD\n") |> String.trim
      )
      :search -> search(IO.gets("what is the game name?\n") |> String.trim)
      _ -> apply(__MODULE__, option, [])
    end
  end
end
