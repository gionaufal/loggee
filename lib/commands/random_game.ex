defmodule Loggee.Commands.RandomGame do
  def call() do
    IO.puts("let's pick a game for you...\n")
    min_time = IO.gets("\nMinimun play time\n-> ") |> String.trim() |> String.to_integer()
    max_time = IO.gets("\nMaximum play time\n-> ") |> String.trim() |> String.to_integer()
    players = IO.gets("\nFor how many players?\n-> ") |> String.trim() |> String.to_integer()
    IO.puts("\nhere's your game:")
    call(System.get_env("BGG_USERNAME"), min_time, max_time, players)
  end

  def call(user, min_time, max_time, players) do
    {:ok, collection} = Loggee.collection(user, :collection)
    collection.games
    |> Enum.filter(fn game ->
      game.play_time <= max_time and game.play_time >= min_time
    end)
    |> Enum.filter(fn game ->
      game.min_players <= players and game.max_players >= players
    end)
    |> get_random_game
  end

  defp get_random_game([]), do: {:error, "No game matches your requirements"}
  defp get_random_game(games), do: Enum.random(games)
end
