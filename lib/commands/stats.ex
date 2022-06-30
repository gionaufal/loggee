defmodule Loggee.Commands.Stats do
  alias Loggee.Bgg.Client.Plays

  def call(user, start_date \\ nil, end_date \\ nil, game_id \\ nil) do
    play_count = Plays.play_count(user, start_date, end_date, game_id)
    IO.puts("Played #{Color.code(069, Integer.to_string(play_count.count))} times (#{play_count.count_solo_plays} solo plays), from #{Color.code(069, Integer.to_string(play_count.distinct_games))} distinct games (#{Enum.count(play_count.borrowed_games)} borrowed, counting expansions).")
    IO.puts("In total, that was #{play_count.hours_played} hours of play time, distributed over #{play_count.distinct_days_played} days during this period.")
    IO.puts("The most played day was #{play_count.most_played_day.date}, with #{play_count.most_played_day.count} plays.")
    IO.write("Played #{Color.code(069, play_count.most_played_game.game)} the most (#{play_count.most_played_game.count}x), ")
    IO.puts("and spent the most time playing #{Color.code(069, play_count.most_played_game_by_time.game)} (#{play_count.most_played_game_by_time.minutes_played} min).")
    IO.puts("Those were the played games:")
    Enum.each(play_count.games, fn game ->
      IO.puts("--- #{game.count}x #{Color.code(069, game.game)} - #{if game.borrowed, do: Color.code(135, "BORROWED"), else: Color.code(040, "OWNED")} - #{game.minutes_played} minutes - Average play time: #{game.avg_play_time} minutes")
    end)
    IO.puts("")
    IO.puts("Of those, the following were played for the first time (including expansions):")
    Enum.each(play_count.new_games, fn game ->
      IO.puts("--- #{Color.code(203, game.game)}")
    end)
  end
end
