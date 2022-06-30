defmodule Loggee.Commands.RandomGameTest do
  use ExUnit.Case
  import Tesla.Mock

  alias Loggee.Commands.RandomGame

  describe "call/4" do
    test "when user asks for a random game, get a game with it's fields" do
      {:ok, body} = File.cwd! |> Path.join("test/fixtures/collection.xml") |> File.read

      mock(fn %{method: :get, url: "https://boardgamegeek.com/xmlapi2/collection?username=g10v45&excludesubtype=boardgameexpansion&own=1&stats=1"} ->
        %Tesla.Env{status: 200, body: body}
      end)

      response = RandomGame.call("g10v45", 15, 45, 3)

      assert %{
        comment: _,
        id: _,
        image: _,
        name: _,
        play_count: _,
        play_time: _,
        min_players: _,
        max_players: _,
        thumbnail: _,
        year: _,
        wishlist_comment: _,
      } = response
    end

    test "when user asks for a random game but there are no matches, return error message" do
      {:ok, body} = File.cwd! |> Path.join("test/fixtures/collection.xml") |> File.read

      mock(fn %{method: :get, url: "https://boardgamegeek.com/xmlapi2/collection?username=g10v45&excludesubtype=boardgameexpansion&own=1&stats=1"} ->
        %Tesla.Env{status: 200, body: body}
      end)

      response = RandomGame.call("g10v45", 15, 45, 7)

      assert {:error, "No game matches your requirements"} = response
    end
  end
end
