defmodule Loggee.Bgg.Client.SearchTest do
  use ExUnit.Case
  import Tesla.Mock

  alias Loggee.Bgg.Client.Search

  describe "call/1" do
    test "when user searches for an existing game" do
      {:ok, body} = File.cwd! |> Path.join("test/fixtures/search.xml") |> File.read

      mock(fn %{method: :get, url: "https://boardgamegeek.com/xmlapi2/search?query=concordia&type=boardgame"} ->
        %Tesla.Env{status: 200, body: body}
      end)

      {:ok, response} = Search.call("concordia")

      assert %{
        count: '11',
        games: [
          %{id: "124361", name: "Concordia", year: '2013'},
          %{id: "325490", name: "Concordia Solitaria", year: '2021'},
          %{id: "256916", name: "Concordia Venus", year: '2018'},
          %{id: "283362", name: "Concordia Venus: Balearica / Italia", year: '2019'},
          %{id: "209574", name: "Concordia: 8 Forum Cards mini-expansion", year: '2016'},
          %{id: "232917", name: "Concordia: Aegyptus / Creta", year: '2017'},
          %{id: "283177", name: "Concordia: Balearica / Cyprus", year: '2019'},
          %{id: "165023", name: "Concordia: Britannia / Germania", year: '2014'},
          %{id: "208364", name: "Concordia: Gallia / Corsica", year: '2016'},
          %{id: "181084", name: "Concordia: Salsa", year: '2015'},
          %{id: "262711", name: "Concordia: Venus (Expansion)", year: '2018'}
        ]
      } == response
    end

    test "when the id doesn't exist, renders map with empty fields" do
      {:ok, body} = File.cwd! |> Path.join("test/fixtures/search_empty.xml") |> File.read

      mock(fn %{method: :get, url: "https://boardgamegeek.com/xmlapi2/search?query=inexistent_game&type=boardgame"} ->
        %Tesla.Env{status: 200, body: body}
      end)

      {:ok, response} = Search.call("inexistent_game")

      assert %{count: '0', games: []} == response
    end
  end

  test "when there is an unexpected error, returns an error" do
    mock(fn %{method: :get, url: "https://boardgamegeek.com/xmlapi2/search?query=banana&type=boardgame"} ->
      {:error, :timeout}
    end)

    response = Search.call("banana")

    expected_response = {:error, :timeout}

    assert response == expected_response
  end
end
