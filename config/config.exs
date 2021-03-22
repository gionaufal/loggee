use Mix.Config

config :ex_gram, token: System.get_env("TELEGRAM_LOGGEE_TOKEN")
import_config "#{Mix.env}.exs"
