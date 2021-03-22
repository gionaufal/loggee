defmodule Loggee.Commands.PostPlay do
  def call() do
    IO.puts("\nWelcome to Loggee! Let's log a play...\n")
    user = System.get_env("BGG_USERNAME")
    {:ok, body} = Loggee.plays(user, nil, nil, "98000")
    user_id = body.user_id
    IO.puts("\nUser: #{user}, id: #{user_id}\n")
    user_player = Loggee.Player.build("me", user, user_id)

    game = IO.gets("\n-> search for the game:\n") |> String.trim()

    {:ok, games} = Loggee.search(game)
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

    play_payload = build_play_payload(date, comments, length, location, game_id, players)

    IO.inspect(play_payload)
    confirm = IO.gets("\n-> confirm play? y/n \n") |> String.trim()

    if confirm == "y" do
      password = System.get_env("BGG_PASSWORD")

      Loggee.Bgg.Client.PostPlays.call(user, password, play_payload)
    end
  end

  defp build_play_payload(date, comments, length, location, game_id, players) do
    %{
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
  end
end
