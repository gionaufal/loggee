defmodule Loggee.Bgg.Client.PostPlays do
  use Tesla

  adapter Tesla.Adapter.Hackney
  plug Tesla.Middleware.JSON
  # plug Tesla.Middleware.Logger

  def call() do
    cookies = authenticate(user: "user", password: "password")

    play_payload = %{
        playdate: "2020-12-29",
        comments: "",
        length: 23,
        twitter: "false",
        minutes: 23,
        location: "Home",
        objectid: "199561",
        hours: 0,
        quantity: "1",
        action: "save",
        players: [
            %{
                username: "g10v45",
                userid: 555323,
                repeat: "true",
                name: "me",
                win: 1,
                score: 44,
                selected: "false"
            },
            %{
                username: nil,
                userid: nil,
                name: "Débora",
                win: 0,
                score: 39,
                selected: "false"
            }
        ],
        objecttype: "thing",
        ajax: 1
    }
    post_play(play_payload, cookies)
  end

  defp authenticate(user: user, password: password) do

    login_payload = %{credentials: %{username: user, password: password}}

    {:ok, response} =
      post("https://boardgamegeek.com/login/api/v1",
        login_payload,
        headers: [{"content-type", "application/json"}])

    [{"Cookie", Enum.join(Tesla.get_headers(response, "set-cookie"), ";")}]
  end

  defp post_play(payload, cookies) do
    {:ok, response} =
      post("https://boardgamegeek.com/geekplay.php",
        payload,
        headers: cookies
      )
  end
  # Methods to get players and locations
  # TODO: use them when building the CLI
  # defp get_players(cookies) do
  #   get("https://boardgamegeek.com/geekplay.php?action=searchplayersandusers&ajax=1&showcount=10",
  #     headers: cookies
  #   )
  # end
  #
  # defp get_locations(cookies) do
  #   get("https://boardgamegeek.com/geekplay.php?action=location&ajax=1&showcount=10",
  #     headers: cookies
  #   )
  # end
end
