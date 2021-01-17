defmodule Loggee.Bgg.Client.Game do
  use Loggee.Bgg.Client

  def call(id) do
    "/thing?id=#{id}&stats=1"
    |> get()
    |> organize_game_payload()
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

  defp organize_game_payload({:error, _reason} = error), do: error
end
