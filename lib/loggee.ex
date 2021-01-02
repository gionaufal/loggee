defmodule Loggee do
  alias Loggee.Bgg.Client.{Collection, Game, Plays, Search}

  defdelegate collection(user, collection), to: Collection, as: :call
  defdelegate game(id), to: Game, as: :call
  defdelegate plays(user, start_date \\ nil, end_date \\ nil), to: Plays, as: :call
  defdelegate search(query), to: Search, as: :call
end
