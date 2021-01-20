defmodule Loggee.Bgg.Client.PostPlays do
  use Tesla

  adapter Tesla.Adapter.Hackney
  plug Tesla.Middleware.JSON

  def call(user, password, play_payload) do
    cookies = authenticate(user: user, password: password)

    post_play(play_payload, cookies)
    |> handle_post()
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
    post("https://boardgamegeek.com/geekplay.php",
      payload,
      headers: cookies
    )
  end

  defp handle_post({:ok, %Tesla.Env{body: body}}) do
    {:ok, %{message: "Play recorded. You have played this game #{body["numplays"]} times"}}
  end

  defp handle_post({_, _response} = error), do: error

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
