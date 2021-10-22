defmodule Loggee.Bgg.Client.GameTest do
  use ExUnit.Case
  import Tesla.Mock

  alias Loggee.Bgg.Client.Game

  describe "call/1" do
    test "when user asks for an existing id" do
      {:ok, body} = File.cwd! |> Path.join("test/fixtures/game.xml") |> File.read

      mock(fn %{method: :get, url: "https://boardgamegeek.com/xmlapi2/thing?id=124361&stats=1"} ->
        %Tesla.Env{status: 200, body: body}
      end)

      {:ok, response} = Game.call("124361")

      assert %{
        description: _,
        id: '124361',
        image: _,
        language_dependence: _,
        name: 'Concordia',
        player_count: _,
        rating: _,
        thumbnail: _,
        weight: _,
        year: _
      } = response
    end

    test "when the id doesn't exist, renders map with empty fields" do
      {:ok, body} = File.cwd! |> Path.join("test/fixtures/game_empty.xml") |> File.read

      mock(fn %{method: :get, url: "https://boardgamegeek.com/xmlapi2/thing?id=00000000&stats=1"} ->
        %Tesla.Env{status: 200, body: body}
      end)

      {:ok, response} = Game.call("00000000")

      assert %{
        description: "",
        id: nil,
        image: nil,
        language_dependence: [],
        name: nil,
        player_count: [],
        rating: nil,
        thumbnail: nil,
        weight: nil,
        year: nil
      } = response
    end
  end

  test "when there is an unexpected error, returns an error" do
    mock(fn %{method: :get, url: "https://boardgamegeek.com/xmlapi2/thing?id=banana&stats=1"} ->
      {:error, :timeout}
    end)

    response = Game.call("banana")

    expected_response = {:error, :timeout}

    assert response == expected_response
  end
end
