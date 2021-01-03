defmodule Loggee do
  alias Loggee.Bgg.Client.{Collection, Game, Plays, PostPlays, Search}

  defdelegate collection(user, collection), to: Collection, as: :call
  defdelegate game(id), to: Game, as: :call
  defdelegate plays(user, start_date \\ nil, end_date \\ nil, id \\ nil), to: Plays, as: :call
  defdelegate search(query), to: Search, as: :call
  defdelegate post_play(user, password, play_payload), to: PostPlays, as: :call

  def start() do
    IO.puts("\nWelcome to Loggee!\n")
    user = IO.gets("\nwhat is your BGG username?\n") |> String.trim()

    game = IO.gets("\nsearch for the game:\n") |> String.trim()

    search(game)

    id = IO.gets("\nwhat is the game id?\n") |> String.trim()
    date = IO.gets("\nwhen did you play it?\n") |> String.trim()
    length = IO.gets("\nfor how long (in minutes)?\n") |> String.trim()
    location = IO.gets("\nwhere?\n") |> String.trim()
    player = IO.gets("\nwho played with you?\n") |> String.trim()
    scores = IO.gets("\nwhat where the scores?\n") |> String.split(",") |> Enum.map(&String.trim/1)
    winner = IO.gets("\nwho won?\n") |> String.split(",") |> Enum.map(&String.trim/1)
    comments = IO.gets("\nany comments? leave blank if no\n") |> String.trim()

    play_payload = %{
      playdate: date,
      comments: comments,
      length: length,
      twitter: "false",
      minutes: length,
      location: location,
      objectid: id,
      hours: 0,
      quantity: "1",
      action: "save",
      players: [
        %{
          username: user,
          userid: 555323,
          repeat: "true",
          name: "me",
          win: Enum.at(winner, 0),
          score: Enum.at(scores, 0),
          selected: "false"
        },
        %{
          username: nil,
          userid: nil,
          repeat: "true",
          name: player,
          win: Enum.at(winner, 1),
          score: Enum.at(scores, 1),
          selected: "false"
        }
      ],
      objecttype: "thing",
      ajax: 1
      }

    confirm = IO.gets("\nconfirm play? y/n \n") |> String.trim()
    IO.inspect(play_payload)

    if confirm == "y" do
      password = IO.gets("\ntype your BGG password\n") |> String.trim()

      post_play(user, password, play_payload)
    end
  end
end
