defmodule Loggee.Bgg.Client.Plays do
  use Loggee.Bgg.Client

  def call(user, start_date \\ nil, end_date \\ nil, game_id \\ nil, page \\ 1, previous_result \\ nil) do
    "/plays?username=#{user}&mindate=#{start_date}&maxdate=#{end_date}&id=#{game_id}&page=#{page}"
    |> get()
    |> organize_plays_payload(start_date, end_date, page, previous_result)
  end

  def play_count(user, start_date \\ nil, end_date \\ nil, game_id \\ nil) do
    {:ok, response} = call(user, start_date, end_date, game_id)

    {:ok, collection} = Loggee.collection(user, :collection)

    games = response.plays
            |> Enum.group_by(&Map.get(&1, :game))
            |> Enum.map(fn {key, value} -> %{
              game: key.name,
              game_id: key.id,
              count: count_plays(value),
              minutes_played: sum_minutes(value),
              new: new?(value),
              expansion: expansion?(value),
              borrowed: borrowed?(collection, value),
              avg_play_time: div(sum_minutes(value), count_plays(value))
            }
            end)
            |> Enum.sort_by(&(&1.count), :desc)

    games_without_expansions = remove_expansions_from_group(games)

    %{
      count: Enum.count(response.plays |> remove_expansions),
      count_solo_plays: count_solo(response.plays |> remove_expansions),
      distinct_games: Enum.count(games_without_expansions),
      distinct_days_played: response.plays |> Enum.group_by(&Map.get(&1, :date)) |> Enum.count,
      most_played_day: response.plays |> Enum.group_by(&Map.get(&1, :date)) |> Enum.map(fn {date, games} -> %{date: date, count: count_plays(games)} end) |> Enum.sort_by(&(&1.count), :desc) |> List.first(),
      hours_played: add_total_time(games_without_expansions),
      most_played_game: List.first(games_without_expansions),
      most_played_game_by_time: games |> Enum.sort_by(&(&1.minutes_played), :desc) |> List.first(),
      new_games: games |> Enum.filter(fn game -> game.new end),
      borrowed_games: games |> Enum.filter(fn game -> game.borrowed end),
      games: games_without_expansions
    }
  end

  def stats(user, start_date \\ nil, end_date \\ nil, game_id \\ nil) do
    play_count = play_count(user, start_date, end_date, game_id)
    IO.puts("Played #{Color.code(069, Integer.to_string(play_count.count))} times (#{play_count.count_solo_plays} solo plays), from #{Color.code(069, Integer.to_string(play_count.distinct_games))} distinct games (#{Enum.count(play_count.borrowed_games)} borrowed, counting expansions).")
    IO.puts("In total, that was #{play_count.hours_played} hours of play time, distributed over #{play_count.distinct_days_played} days during this period")
    IO.puts("The most played day was #{play_count.most_played_day.date}, with #{play_count.most_played_day.count} plays")
    IO.write("Played #{play_count.most_played_game.game} the most (#{play_count.most_played_game.count}x), ")
    IO.puts("and spent the most time playing #{play_count.most_played_game_by_time.game} (#{play_count.most_played_game_by_time.minutes_played} min)")
    IO.puts("Those were the played games:")
    Enum.each(play_count.games, fn game ->
      IO.puts("--- #{game.count}x #{Color.code(069, game.game)} - #{if game.borrowed, do: Color.code(135, "BORROWED"), else: Color.code(040, "OWNED")} - #{game.minutes_played} minutes - Average play time: #{game.avg_play_time}")
    end)
    IO.puts("Of those, the following were played for the first time (including expansions):")
    Enum.each(play_count.new_games, fn game ->
      IO.puts("--- #{Color.code(203, game.game)}")
    end)
  end

  defp add_total_time(games) do
    (games
    |> Enum.map(fn game -> game.minutes_played end)
    |> Enum.sum)/60
    |> Float.round(2)
  end

  defp count_plays(game) do
    Enum.count(game)
  end

  defp sum_minutes(game) do
    Enum.map(game, fn x -> x.length end) |> Enum.sum()
  end

  defp organize_plays_payload(result, start_date, end_date, page, previous_result)

  defp organize_plays_payload({:ok, %Tesla.Env{body: body}}, start_date, end_date, page, previous_result) do
    result =  body |> xmap(
      count: ~x"//plays/@total"I,
      username: ~x"//plays/@username"s,
      user_id: ~x"//plays/@userid",
      plays: [
        ~x"//play"l,
        comment: ~x"//comments/text()"s,
        date: ~x"./@date",
        game: [
          ~x"//item",
          name: ~x"//@name"s,
          id: ~x"//@objectid",
          subtypes: ~x"//subtype/@value"sl
        ],
        id: ~x"./@id",
        length: ~x"./@length"I,
        location: ~x"./@location",
        players: [
          ~x"//players/player"l,
          username: ~x"./@username",
          name: ~x"./@name"s,
          score: ~x"./@score",
          win: ~x"./@win",
          new: ~x"./@new"I
        ]
      ]
    )

    result = if previous_result do
      Map.put(result, :plays, Enum.concat(previous_result.plays, result.plays))
    else
      result
    end

    current_count = Enum.count(result.plays)

    iterate_plays(result, start_date, end_date, page, current_count)
  end

  defp organize_plays_payload({:error, _reason} = error, _, _, _, _), do: error

  defp iterate_plays(result, _, _, _, current_count) when result.count == current_count do
    {:ok, result}
  end

  defp iterate_plays(result, start_date, end_date, page, _) do
    call(result.username, start_date, end_date, nil, page + 1, result)
  end

  defp remove_expansions(plays) do
    plays
    |> Enum.filter(fn play ->
      !Enum.member?(play.game.subtypes, "boardgameexpansion")
    end)
  end

  defp remove_expansions_from_group(games) do
    games
    |> Enum.filter(fn game -> !game.expansion end)
  end

  defp count_solo(plays) do
    plays
    |> Enum.filter(fn play ->
      String.downcase(play.comment) =~ "solo"
    end)
    |> Enum.count
  end

  defp new?(plays) do
    plays
    |> Enum.any?(fn play -> Enum.at(play.players, 0).new == 1 end)
  end

  defp expansion?(plays) do
    plays
    |> Enum.any?(fn play -> Enum.member?(play.game.subtypes, "boardgameexpansion") end)
  end

  defp borrowed?(collection, games) do
    names = Enum.map(collection.games, fn x -> x.name end)
    !Enum.member?(names, List.first(games).game.name)
  end
end
