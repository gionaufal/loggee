defmodule Loggee.Bgg.Client.PlaysTest do
  use ExUnit.Case
  import Tesla.Mock

  alias Loggee.Bgg.Client.Plays

  describe "call/4" do
    test "when user asks for all their plays" do
      {:ok, body} = File.cwd! |> Path.join("test/fixtures/plays.xml") |> File.read

      mock(fn %{method: :get, url: "https://boardgamegeek.com/xmlapi2/plays?username=g10v45&mindate=&maxdate=&id=&page=1"} ->
        %Tesla.Env{status: 200, body: body}
      end)

      {:ok, response} = Plays.call("g10v45")

      assert  %{
        count: 4,
        plays: [
          %{comment: "Played with all expansions except shields and routes",
            date: '2021-01-06',
            game: %{
              id: '271320',
              name: 'The Castles of Burgundy',
              subtypes: ["boardgame", "boardgamecompilation", "boardgameimplementation"]
            },
            id: '48279045',
            length: 78,
            location: 'Home',
            players: [
              %{name: "me", score: '180', username: 'g10v45', win: '1'},
              %{name: "Débora", score: '175', username: [], win: '0'}
            ]},
          %{comment: "Military",
            date: '2021-01-03',
            game: %{id: '173346', name: '7 Wonders Duel', subtypes: ["boardgame", "boardgameimplementation"]},
            id: '48205103', length: 20, location: 'Home',
            players: [%{name: "me", score: '10', username: 'g10v45', win: '1'},
              %{name: "Débora", score: '0', username: [], win: '0'}]},
          %{comment: "Hispania map w/ salsa, finished with houses",
            date: '2021-01-02',
            game: %{id: '124361', name: 'Concordia', subtypes: ["boardgame"]},
            id: '48205060', length: 60, location: 'Home',
            players: [%{name: "me", score: '161', username: 'g10v45', win: '1'},
              %{name: "Débora", score: '139', username: [], win: '0'}]},
          %{comment: "", date: '2020-12-31',
            game: %{id: '54043', name: 'Jaipur', subtypes: ["boardgame"]},
            id: '48205013', length: 44, location: 'Home',
            players: [%{name: "me", score: '2', username: 'g10v45', win: '1'},
              %{name: "Débora", score: '1', username: [], win: '0'}
            ]}
          ],
          user_id: '555323',
          username: "g10v45"
          } == response
    end
  end

  test "when there is an unexpected error, returns an error" do
    mock(fn %{method: :get, url: "https://boardgamegeek.com/xmlapi2/plays?username=banana&mindate=&maxdate=&id=&page=1"} ->
      {:error, :timeout}
    end)

    response = Plays.call("banana")

    expected_response = {:error, :timeout}

    assert response == expected_response
  end
end
