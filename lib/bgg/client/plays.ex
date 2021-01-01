defmodule Loggee.Bgg.Client.Plays do
  use Tesla
  import SweetXml

  plug Tesla.Middleware.BaseUrl, "https://boardgamegeek.com/xmlapi2"

  def call(user, start_date \\ nil, end_date \\ nil) do
    "/plays?username=#{user}&mindate=#{start_date}&maxdate=#{end_date}"
    |> get()
    |> organize_plays_payload
  end

  defp organize_plays_payload({:ok, %Tesla.Env{body: body}}) do
    result =  body |> xmap(
      count: ~x"//plays/@total",
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
