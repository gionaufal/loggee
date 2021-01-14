defmodule Loggee.Bot do
  @bot :loggee

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  command("start")
  command("random")
  command("help", description: "Print the bot's help")

  middleware(ExGram.Middleware.IgnoreUsername)

  def bot(), do: @bot

  def handle({:command, :start, _msg}, context) do
    answer(context, "Hi!")
  end

  def handle({:command, :random, msg}, context) do
    [user, time] = String.split(msg.text, " ")
    game = Loggee.Commands.RandomGame.call(user, String.to_integer(time))
    answer(context, "Here's a game for you: \n#{game.name} \nplay time: #{game.play_time}\nplay count: #{game.play_count}
      ")
  end

  def handle({:command, :help, _msg}, context) do
    answer(context, "Here is your help:")
  end
end
