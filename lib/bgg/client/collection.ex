defmodule Loggee.Bgg.Client.Collection do
  use Loggee.Bgg.Client

  plug Tesla.Middleware.Retry,
    delay: 500,
    max_retries: 10,
    max_delay: 1_000,
    should_retry: fn
      {:ok, %{status: status}} when status == 202 -> true
      {:ok, _} -> false
      {:error, _} -> false
    end

  def call(user, _collection = :collection) do
    "/collection?username=#{user}&excludesubtype=boardgameexpansion&own=1&stats=1"
    |> get()
    |> organize_collection_payload()
  end

  def call(user, _collection = :wishlist) do
    "/collection?username=#{user}&excludesubtype=boardgameexpansion&wishlist=1&wishlistpriority=1&wishlistpriority=2&stats=1"
    |> get()
    |> organize_collection_payload()
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
        play_count: ~x"//numplays/text()"I,
        play_time: ~x"//stats/@playingtime"I,
        min_players: ~x"//stats/@minplayers"I,
        max_players: ~x"//stats/@maxplayers"I,
        thumbnail: ~x"//thumbnail/text()",
        year: ~x"//yearpublished/text()",
        wishlist_comment: ~x"//wishlistcomment/text()"
      ]
    )
    {:ok, result}
  end
end
