defmodule Loggee.Bgg.Client.Search do
  use Loggee.Bgg.Client

  def call(name) do
    query = name |> String.replace(" ", "+")
    "/search?query=#{query}&type=boardgame"
    |> get()
    |> organize_search_payload()
  end

  defp organize_search_payload({:ok, %Tesla.Env{body: body}}) do
    result =  body |> xmap(
      count: ~x"//items/@total",
      games: [
        ~x"//item"l,
        id: ~x"./@id"s,
        name: ~x"//name/@value"s,
        year: ~x"//yearpublished/@value"
      ]
    )
    {:ok, result}
  end

  defp organize_search_payload({:error, _reason} = error), do: error
end
