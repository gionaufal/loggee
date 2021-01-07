defmodule Loggee.Player do
  @required_keys [:name]

  @enforce_keys @required_keys
  @derive Jason.Encoder
  defstruct [:name, :username, :userid, :win, :repeat, :score, :selected]

  def build(name, username \\ nil, user_id \\ nil, win \\ 0, score \\ 0) do
    %Loggee.Player{
      username: username,
      userid: user_id,
      repeat: "true",
      name: name,
      win: win,
      score: score,
      selected: "false"
    }
  end
end
