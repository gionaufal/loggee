defmodule Loggee.Bgg.Client.Plays do
  use Loggee.Bgg.Client

  def call(user, start_date \\ nil, end_date \\ nil, game_id \\ nil, page \\ 1, previous_result \\ nil) do
    "/plays?username=#{user}&mindate=#{start_date}&maxdate=#{end_date}&id=#{game_id}&page=#{page}"
    |> get()
    |> organize_plays_payload(start_date, end_date, page, previous_result)
  end

  def play_count(user, start_date \\ nil, end_date \\ nil, game_id \\ nil) do
    {:ok, response} = call(user, start_date, end_date, game_id)

    games = response.plays
            |> remove_expansions
            |> Enum.group_by(&Map.get(&1, :game))
            |> Enum.map(fn {key, value} -> %{
              game: key.name,
              game_id: key.id,
              count: Enum.count(value)
            }
            end)
            |> Enum.sort_by(&(&1.count), :desc)

    %{
      count: Enum.count(response.plays),
      games: games
    }
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
          name: ~x"//@name",
          id: ~x"//@objectid",
          subtypes: ~x"//subtype/@value"sl
        ],
        id: ~x"./@id",
        length: ~x"./@length",
        location: ~x"./@location",
        players: [
          ~x"//players/player"l,
          username: ~x"./@username",
          name: ~x"./@name"s,
          score: ~x"./@score",
          win: ~x"./@win"
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
end
