defmodule Loggee.Bot do
  @bot :loggee

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  @cmds [
    %{command: "start", description: "Says Hi"},
    %{command: "random", description: "Gets a random game from your collection to be played in a given time\\. Usage: `/random BGG_USERNAME 90`"},
    %{command: "search", description: "Searches for game name in BGG, returns game name and ID\\. Usage `/search concordia`"},
    %{command: "game", description: "Gets game info when given a BGG ID\\. Usage: `/game 124361`"},
    %{command: "help", description: "Print options"},
  ]

  # Enum.map(@commands, fn c ->
  #   command(c.command, description: c.description)
  # end)

  command("start")
  command("random", description: "Gets a random game from your collection to be played in a given time. Usage: /random BGG_USERNAME TIME")
  command("search", description: "Searches for game name in BGG, returns game name and ID. Usage /search concordia")
  command("game", description: "Gets game info when given a BGG ID. Usage: /game 124361")
  command("help", description: "Print the bot's options")

  middleware(ExGram.Middleware.IgnoreUsername)

  def bot(), do: @bot

  def handle({:command, :start, _msg}, context) do
    answer(context, "Hi!")
  end

  def handle({:command, :random, msg}, context) do
    [user, time] = String.split(msg.text, " ")
    game = Loggee.Commands.RandomGame.call(user, String.to_integer(time))
    answer(context, "Here's a game for you: \n#{game.name} \nplay time: #{game.play_time}\nplay count: #{game.play_count}")
  end

  def handle({:command, :search, msg}, context) do
    results = msg.text
              |> Loggee.search()
              |> handle_search()
              |> build_keyboard()

    ExGram.send_message(context.update.message.chat.id,
      "Search results",
      reply_markup: results)
  end

  def handle({:callback_query, %{data: id}}, context) do
    result = id
              |> Loggee.game()
              |> handle_game()
    answer(context, result)
  end

  def handle({:command, :game, msg}, context) do
    result = msg.text
              |> Loggee.game()
              |> handle_game()
    answer(context, result)
  end

  def handle({:command, :help, _msg}, context) do
    help = handle_help()
    answer(context, "#{Enum.map(help, fn h -> h end)}", parse_mode: "MarkdownV2")
  end

  defp handle_search({:ok, results}) do
    results.games
  end

  defp handle_game({:ok, result}) do
    "id: #{result.id},
     name: #{result.name},
     description: #{result.description},
     weight: #{result.weight},
     rating: #{result.rating}"
  end

  defp handle_help() do
    Enum.map(@cmds, fn c ->
      "/#{c.command} \\- #{c.description}\n"
    end)
  end

  defp build_keyboard(results) do
    buttons = Enum.map(results, fn result ->
      [%ExGram.Model.InlineKeyboardButton{
        text: "#{result.name} (#{result.year}), id: #{result.id}",
        callback_data: result.id
      }]
    end)

    %ExGram.Model.InlineKeyboardMarkup{inline_keyboard: buttons}
  end
end
