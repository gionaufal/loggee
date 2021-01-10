defmodule Loggee.Commands.RandomGame do
  def call() do
    IO.puts("let's pick a game for you...\n")
    time = IO.gets("\nhow long do you want to play?\n-> ") |> String.trim() |> String.to_integer()
    IO.puts("\nhere's your game:")
    call(System.get_env("BGG_USERNAME"), time)
  end

  def call(user, time) do
    {:ok, collection} = Loggee.collection(user, :collection)
    collection.games
    |> Enum.filter(fn game -> game.play_time <= time end)
    |> Enum.random
  end
end
