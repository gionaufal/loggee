defmodule Loggee.Bgg.Client do
  defmacro __using__(_opts) do
    quote do
      use Tesla
      import SweetXml

      plug Tesla.Middleware.BaseUrl, "https://boardgamegeek.com/xmlapi2"
    end
  end
end
