defmodule Loggee.Commands.RandomGame do
  def call() do
    IO.puts("\nlet's pick a game for you\n")
    time = IO.gets("\n-> how long do you want to play?\n") |> String.trim() |> String.to_integer()
    {:ok, collection} = Loggee.collection(System.get_env("BGG_USERNAME"), "collection")
    game = collection.games
    |> Enum.filter(fn game -> game.play_time <= time end)
    |> Enum.random

    IO.puts("\nhere's a game for you:")
    IO.inspect(game)
  end
end
