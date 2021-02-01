defmodule Loggee.Bgg.Client.Plays do
  use Loggee.Bgg.Client

  def call(user, start_date \\ nil, end_date \\ nil, game_id \\ nil) do
    "/plays?username=#{user}&mindate=#{start_date}&maxdate=#{end_date}&id=#{game_id}"
    |> get()
    |> organize_plays_payload
  end

  # TODO: improve this method to count all occurrences, right now it's
  # only counting the first page of the plays endpoint (100 entries).
  def play_count(user, start_date \\ nil, end_date \\ nil, game_id \\ nil) do
    {:ok, response} = call(user, start_date, end_date, game_id)

    response.plays
    |> Enum.group_by(&Map.get(&1, :game))
    |> Enum.map(fn {key, value} -> %{
      game: key.name,
      play_count: Enum.count(value)
    }
    end)
    |> Enum.sort_by(&(&1.play_count), :desc)
  end

  defp organize_plays_payload({:ok, %Tesla.Env{body: body}}) do
    result =  body |> xmap(
      count: ~x"//plays/@total",
      user_id: ~x"//plays/@userid",
      plays: [
        ~x"//play"l,
        comment: ~x"//comments/text()"s,
        date: ~x"./@date",
        game: [
          ~x"//item",
          name: ~x"//@name",
          id: ~x"//@objectid",
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
    {:ok, result}
  end

  defp organize_plays_payload({:error, _reason} = error), do: error
end
