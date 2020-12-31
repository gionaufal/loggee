defmodule Loggee.Bgg.Client do
  use Tesla
  import SweetXml

  plug Tesla.Middleware.BaseUrl, "https://boardgamegeek.com/xmlapi2"

  def search(name) do
    "/search?query=#{name}&type=boardgame"
    |> get()
    |> organize_search_payload()
  end

  def game(id) do
    "/thing?id=#{id}&stats=1"
    |> get()
    |> organize_game_payload()
  end

  defp organize_search_payload({:ok, %Tesla.Env{body: body}}) do
    result =  body |> xmap(
      total: ~x"//items/@total",
      games: [
        ~x"//item"l,
        id: ~x"./@id",
        name: ~x"//name/@value",
        year: ~x"//yearpublished/@value",
      ]
    )
    {:ok, result}
  end

  defp organize_game_payload({:ok, %Tesla.Env{body: body}}) do
    result = body |> xmap(
      description: ~x"//description/text()",
      id: ~x"//item/@id",
      language_dependence: [
        ~x"//poll[@name='language_dependence']//result"l,
        value: ~x"./@value",
        votes: ~x"./@numvotes",
      ],
      name: ~x"//name[@type='primary']/@value",
      player_count: [
        ~x"//poll[@name='suggested_numplayers']/results"l,
        value: ~x"./@numplayers",
        best: ~x".//result[@value='Best']/@numvotes",
        recommended:  ~x".//result[@value='Recommended']/@numvotes"
      ],
      rating: ~x"//statistics/ratings/average/@value",
      weight: ~x"//statistics/ratings/averageweight/@value",
      year: ~x"//yearpublished/@value"
    )
    {:ok, result}
  end
end
