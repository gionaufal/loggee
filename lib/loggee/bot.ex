defmodule Loggee.Bot do
  @bot :loggee

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  command("start", description: "Says Hi")
  command("random", description: "Gets a random game from your collection to be played in a given time\\. Usage: `/random BGG_USERNAME 90`")
  command("search", description: "Searches for game name in BGG, returns game name and ID\\. Usage `/search concordia`")
  command("game", description: "Gets game info when given a BGG ID\\. Usage: `/game 124361`")
  command("wishlist", description: "Gets wishlist from given player in BGG")
  command("plays", description: "Gets plays from a given player in a given timeframe\\. Usage: `/plays BGG_USERNAME 2021-01-01 2021-01-03`")
  command("playcount", description: "Gets play count from games from a given player in a given timeframe\\. Usage: `/plays BGG_USERNAME 2021-01-01 2021-01-03`")
  command("help", description: "Print the bot's options")

  middleware(ExGram.Middleware.IgnoreUsername)

  def bot(), do: @bot

  def handle({:command, :start, _msg}, context) do
    answer(context, "Hi, this is the Loggee Bot, where you can interact with BGG in an easy way! Send /help for a list of commands")
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

  def handle({:command, :wishlist, msg}, context) do
    results = msg.text
              |> Loggee.wishlist(:wishlist)
              |> handle_wishlist()
    answer(context, "#{Enum.map(results, fn result -> result end)}")
  end

  def handle({:command, :plays, msg}, context) do
    [user, start_date, end_date] = String.split(msg.text, " ")
    results = user
             |> Loggee.plays(start_date, end_date)
             |> handle_plays()
    answer(context, "#{Enum.map(results, fn result -> result end)}")
  end

  def handle({:command, :playcount, msg}, context) do
    [user, start_date, end_date] = String.split(msg.text, " ")
    results = user
             |> Loggee.play_count(start_date, end_date)
             |> handle_playcount()
    answer(context, "#{Enum.map(results, fn result -> result end)}")
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

  defp handle_wishlist({:ok, results}) do
    results.games
    |> Enum.map(fn result ->
      " name: #{result.name}
       id: #{result.id}
       comment: #{result.wishlist_comment}
       play time: #{result.play_time}
       player count: #{result.min_players} - #{result.max_players}
       year: #{result.year}
      ---------
      "
    end)
  end

  defp handle_plays({:ok, results}) do
    results.plays
    |> Enum.map(fn result ->
      "game: #{result.game.name}
       date: #{result.date}
       comment: #{result.comment}
       length: #{result.length}
       location: #{result.location}
       players: #{Enum.map(result.players, fn player -> "#{player.name} - score: #{player.score} - win: #{player.win}" end)}
      ---------
      "
    end)
  end

  defp handle_playcount(results) do
    results
    |> Enum.map(fn result ->
      "#{result.count}x #{result.game}\n"
    end)
  end

  defp handle_help() do
    Enum.map(@commands, fn c ->
      {:ok, name} = Keyword.fetch(c, :command)
      {:ok, description} = Keyword.fetch(c, :description)
      "/#{name} \\- #{description}\n"
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
