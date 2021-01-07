defmodule Loggee do
  alias Loggee.Bgg.Client.{Collection, Game, Plays, PostPlays, Search}

  defdelegate collection(user, collection), to: Collection, as: :call
  defdelegate game(id), to: Game, as: :call
  defdelegate plays(user, start_date \\ nil, end_date \\ nil, id \\ nil), to: Plays, as: :call
  defdelegate search(query), to: Search, as: :call
  defdelegate post_play(user, password, play_payload), to: PostPlays, as: :call

  def start() do
    IO.puts("\nWelcome to Loggee! Let's log a play...\n")
    user = IO.gets("\n-> what is your BGG username?\n") |> String.trim()
    {:ok, body} = plays(user, nil, nil, "98000")
    user_id = body.user_id
    IO.puts("\nUser: #{user}, id: #{user_id}\n")
    user_player = Loggee.Player.build("me", user, user_id)

    game = IO.gets("\n-> search for the game: (replace spaces with `+`)\n") |> String.trim()

    {:ok, games} = search(game)
    IO.puts("Count: #{games.count}")
    games.games
    |> Enum.with_index()
    |> Enum.each(fn {game, index} ->
      IO.puts("[#{index}] - ID: #{game.id}, name: #{game.name}, year: #{game.year}")
    end)

    game_index = IO.gets("\n-> choose a game\n") |> String.trim() |> String.to_integer()
    game_id = Enum.at(games.games, game_index).id
    IO.puts("Your choice: #{game_id}")
    date = IO.gets("\n-> when did you play it? (YYYY-MM-DD)\n") |> String.trim()
    length = IO.gets("\n-> for how long (in minutes)?\n") |> String.trim()
    location = IO.gets("\n-> where?\n") |> String.trim()
    players = IO.gets("\n-> who played with you? (just names, comma separated)\n")
              |> String.split(",")
              |> Enum.map(&String.trim/1)
              |> Enum.map(fn name -> Loggee.Player.build(name) end)
    players = [user_player | players]
    scores = IO.gets("\n-> what where the scores? (Your score, opponnent scores, comma separated)\n") |> String.split(",") |> Enum.map(&String.trim/1)
    winners = IO.gets("\n-> who won? (ex: 1, 0)\n") |> String.split(",") |> Enum.map(&String.trim/1)
    comments = IO.gets("\n-> any comments? (leave blank if no)\n") |> String.trim()

    players = players
              |> Enum.with_index
              |> Enum.map(fn {player, index} ->
                %{player | score: Enum.at(scores, index), win: Enum.at(winners, index)}
              end)

    play_payload = %{
      playdate: date,
      comments: comments,
      length: length,
      twitter: "false",
      minutes: length,
      location: location,
      objectid: game_id,
      hours: 0,
      quantity: "1",
      action: "save",
      players: players,
      objecttype: "thing",
      ajax: 1
      }

    IO.inspect(play_payload)
    confirm = IO.gets("\n-> confirm play? y/n \n") |> String.trim()

    if confirm == "y" do
      password = IO.gets("\n-> type your BGG password\n") |> String.trim()

      post_play(user, password, play_payload)
    end
  end

  def random_game() do
    user = IO.gets("\n-> what is your BGG username?\n") |> String.trim()
    time = IO.gets("\n-> how long do you want to play?\n") |> String.trim() |> String.to_integer()
    {:ok, collection} = collection(user, "collection")
    game = collection.games
    |> Enum.filter(fn game -> game.play_time <= time end)
    |> Enum.random

    IO.puts("\nhere's a game for you:")
    IO.inspect(game)
  end
end
