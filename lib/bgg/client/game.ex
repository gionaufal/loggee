defmodule Loggee.Bgg.Client.Game do
  use Loggee.Bgg.Client

  def call(id) do
    "/thing?id=#{id}&stats=1"
    |> get()
    |> organize_game_payload()
  end

  defp organize_game_payload({:ok, %Tesla.Env{body: body}}) do
    result = body |> xmap(
      description: ~x"//description/text()"s,
      id: ~x"//item/@id",
      image: ~x"//image/text()",
      language_dependence: [
        ~x"//poll[@name='language_dependence']//result"l,
        value: ~x"./@value",
        votes: ~x"./@numvotes"I,
      ],
      name: ~x"//name[@type='primary']/@value",
      player_count: [
        ~x"//poll[@name='suggested_numplayers']/results"l,
        value: ~x"./@numplayers",
        votes: [
          ~x".",
          best: ~x".//result[@value='Best']/@numvotes"I,
          recommended:  ~x".//result[@value='Recommended']/@numvotes"I,
          not_recommended:  ~x".//result[@value='Not Recommended']/@numvotes"I
        ]
      ],
      rating: ~x"//statistics/ratings/average/@value",
      thumbnail: ~x"//thumbnail/text()",
      weight: ~x"//statistics/ratings/averageweight/@value",
      year: ~x"//yearpublished/@value"
    )
    {:ok, update_player_count(result)}
  end

  defp organize_game_payload({:error, _reason} = error), do: error

  defp update_player_count(payload) do
    percentage = get_play_count_percentage(payload)

    updated = payload.player_count
    |> Enum.with_index
    |> Enum.map(fn {count, index} ->
      Map.put(count, :votes, Enum.at(percentage, index))
    end)

    Map.put(payload, :player_count, updated)
  end

  defp get_play_count_percentage(payload) do
    payload
    |> sum_play_count
    |> Enum.with_index
    |> Enum.map(fn {sum, index} ->
      Enum.at(payload.player_count, index).votes
      |> Enum.into(%{}, fn {k, v} -> {k, v / sum} end)
    end)
  end

  defp sum_play_count(payload) do
    payload.player_count
    |> Enum.map(fn count ->
      count.votes
      |> Map.values()
      |> Enum.sum()
    end)
  end
end
