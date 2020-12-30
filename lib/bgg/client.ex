defmodule Loggee.Bgg.Client do
  use Tesla
  import SweetXml

  plug Tesla.Middleware.BaseUrl, "https://boardgamegeek.com/xmlapi2"

  def search(name) do
    "/search?query=#{name}&type=boardgame"
    |> get()
    |> handle_get()
    |> organize_search_payload()
  end

  def game(id) do
    "/thing?id=#{id}&stats=1"
    |> get()
    |> organize_game_payload()
  end

  defp handle_get({:ok, %Tesla.Env{status: 200, body: body}}) do
    {:ok, XmlToMap.naive_map(body)}
  end

  defp organize_search_payload({:ok, payload}) do
    items = payload["items"]
    games = items["#content"]["item"] |> Enum.map(fn game ->
      %{
        name: game["#content"]["name"]["-value"],
        year: game["#content"]["yearpublished"]["-value"],
        id: game["-id"]
      }
    end)
    {:ok, %{games: games, total: items["-total"]}}
  end

  defp organize_game_payload({:ok, %Tesla.Env{body: body}}) do
    body |> xmap(
      name: ~x"//name[@type='primary']/@value",
      description: ~x"//description/text()",
      year_published: ~x"//yearpublished/@value",
      id: ~x"//item/@id",
      rating: ~x"//statistics/ratings/average/@value",
      weight: ~x"//statistics/ratings/averageweight/@value",
      suggested_players: [
        ~x"//poll[@name='suggested_numplayers']/results"l,
        value: ~x"./@numplayers",
        best: ~x".//result[@value='Best']/@numvotes",
        recommended:  ~x".//result[@value='Recommended']/@numvotes"
      ],
      language_dependence: [
        ~x"//poll[@name='language_dependence']//result"l,
        value: ~x"./@value",
        votes: ~x"./@numvotes",
      ])
  end
end
