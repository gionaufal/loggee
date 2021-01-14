defmodule Loggee.Bgg.Client.CollectionTest do
  use ExUnit.Case
  import Tesla.Mock

  alias Loggee.Bgg.Client.Collection

  describe "call/2" do
    test "when user has a collection of games" do
      {:ok, body} = File.cwd! |> Path.join("test/fixtures/collection.xml") |> File.read

      mock(fn %{method: :get, url: "https://boardgamegeek.com/xmlapi2/collection?username=g10v45&excludesubtype=boardgameexpansion&own=1&stats=1"} ->
        %Tesla.Env{status: 200, body: body}
      end)

      {:ok, response} = Collection.call("g10v45", :collection)

      assert %{count: 2, games: [%{name: '7 Wonders Duel'}, %{name: 'Azul'}]} = response
    end

    test "when user has no games in their collection" do
      {:ok, body} = File.cwd! |> Path.join("test/fixtures/collection_empty.xml") |> File.read

      mock(fn %{method: :get, url: "https://boardgamegeek.com/xmlapi2/collection?username=banana&excludesubtype=boardgameexpansion&own=1&stats=1"} ->
        %Tesla.Env{status: 200, body: body}
      end)

      {:ok, response} = Collection.call("banana", :collection)

      assert %{count: 0, games: []} = response
    end

    test "when user asks for wishlist" do
      {:ok, body} = File.cwd! |> Path.join("test/fixtures/wishlist.xml") |> File.read

      mock(fn %{method: :get, url: "https://boardgamegeek.com/xmlapi2/collection?username=g10v45&excludesubtype=boardgameexpansion&wishlist=1&wishlistpriority=1&wishlistpriority=2&stats=1"} ->
        %Tesla.Env{status: 200, body: body}
      end)

      {:ok, response} = Collection.call("g10v45", :wishlist)

      assert %{count: 3, games: [%{name: '7 Wonders'}, %{name: 'Air, Land, Sea'}, %{name: 'Altiplano'}]} = response
    end
  end

  test "when there is an unexpected error, returns an error" do
    mock(fn %{method: :get, url: "https://boardgamegeek.com/xmlapi2/collection?username=banana&excludesubtype=boardgameexpansion&own=1&stats=1"} ->
      {:error, :timeout}
    end)

    response = Collection.call("banana", :collection)

    expected_response = {:error, :timeout}

    assert response == expected_response
  end
end
