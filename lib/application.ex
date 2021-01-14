defmodule Loggee.Application do
  use Application

  def start(_type, _args) do
    children = [
      ExGram,
      {Loggee.Bot, [method: :polling, token: Application.get_env(:ex_gram, :token)]}
    ]

    opts = [strategy: :one_for_one, name: Loggee.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
