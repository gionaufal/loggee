defmodule Loggee.Bgg.Client do
  use Tesla
  import SweetXml

  plug Tesla.Middleware.BaseUrl, "https://boardgamegeek.com/xmlapi2"
  plug Tesla.Middleware.Retry,
    delay: 500,
    max_retries: 10,
    max_delay: 1_000,
    should_retry: fn
      {:ok, %{status: status}} when status == 202 -> true
      {:ok, _} -> false
      {:error, _} -> false
    end

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

  def collection(user) do
    "/collection?username=#{user}&excludesubtype=boardgameexpansion&own=1"
    |> get()
    |> organize_collection_payload()
  end

  def wishlist(user) do
    "/collection?username=#{user}&excludesubtype=boardgameexpansion&wishlist=1&wishlistpriority=1&wishlistpriority=2"
    |> get()
    |> organize_collection_payload()
  end

  defp organize_search_payload({:ok, %Tesla.Env{body: body}}) do
    result =  body |> xmap(
      count: ~x"//items/@total",
      games: [
        ~x"//item"l,
        id: ~x"./@id",
        name: ~x"//name/@value",
        year: ~x"//yearpublished/@value"
      ]
    )
    {:ok, result}
  end

  defp organize_game_payload({:ok, %Tesla.Env{body: body}}) do
    result = body |> xmap(
      description: ~x"//description/text()",
      id: ~x"//item/@id",
      image: ~x"//image/text()",
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
      thumbnail: ~x"//thumbnail/text()",
      weight: ~x"//statistics/ratings/averageweight/@value",
      year: ~x"//yearpublished/@value"
    )
    {:ok, result}
  end

  defp organize_collection_payload({:ok, %Tesla.Env{body: body}}) do
    result = body |> xmap(
      count: ~x"//items/@totalitems",
      games: [
        ~x"//item"l,
        comment: ~x"//comment/text()",
        id: ~x"./@objectid",
        image: ~x"//image/text()",
        name: ~x"//name/text()",
        play_count: ~x"//numplays/text()",
        thumbnail: ~x"//thumbnail/text()",
        year: ~x"//yearpublished/text()",
        wishlist_comment: ~x"//wishlistcomment/text()"
      ]
    )
    {:ok, result}
  end
end
