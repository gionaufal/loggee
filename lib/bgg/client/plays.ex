defmodule Loggee.Bgg.Client.Plays do
  use Loggee.Bgg.Client

  def call(user, start_date \\ nil, end_date \\ nil, game_id \\ nil) do
    "/plays?username=#{user}&mindate=#{start_date}&maxdate=#{end_date}&id=#{game_id}"
    |> get()
    |> organize_plays_payload
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
end
