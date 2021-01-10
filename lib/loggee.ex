defmodule Loggee do
  alias Loggee.Bgg.Client.{Collection, Game, Plays, Search}
  alias Loggee.Commands

  defdelegate collection(user, collection), to: Collection, as: :call
  defdelegate wishlist(user, collection), to: Collection, as: :call
  defdelegate game(id), to: Game, as: :call
  defdelegate plays(user, start_date \\ nil, end_date \\ nil, id \\ nil), to: Plays, as: :call
  defdelegate search(query), to: Search, as: :call
  defdelegate post_play(), to: Commands.PostPlay, as: :call
  defdelegate random_game(), to: Commands.RandomGame, as: :call
end
