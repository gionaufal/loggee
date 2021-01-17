defmodule Loggee.Commands.RandomGameTest do
  use ExUnit.Case
  import Tesla.Mock

  alias Loggee.Commands.RandomGame

  describe "call/2" do
    test "when user asks for a random game, get a game with it's fields" do
      {:ok, body} = File.cwd! |> Path.join("test/fixtures/collection.xml") |> File.read

      mock(fn %{method: :get, url: "https://boardgamegeek.com/xmlapi2/collection?username=g10v45&excludesubtype=boardgameexpansion&own=1&stats=1"} ->
        %Tesla.Env{status: 200, body: body}
      end)

      response = RandomGame.call("g10v45", "45")

      assert %{
        comment: _,
        id: _,
        image: _,
        max_players: _,
        min_players: _,
        name: _,
        play_count: _,
        play_time: _,
        thumbnail: _,
        wishlist_comment: _,
        year: _
      } = response
    end
  end
end
