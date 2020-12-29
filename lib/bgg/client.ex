defmodule Loggee.Bgg.Client do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://boardgamegeek.com/xmlapi2"

  def search(name) do
    "/search?query=#{name}&type=boardgame"
    |> get()
    |> handle_get()
    |> organize_payload()
  end

  defp handle_get({:ok, %Tesla.Env{status: 200, body: body}}) do
    {:ok, XmlToMap.naive_map(body)}
  end

  defp organize_payload({:ok, payload}) do
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
end
