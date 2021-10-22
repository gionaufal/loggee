defmodule Color do
  def code(code, text) do
    IO.ANSI.color(code) <> text <> IO.ANSI.reset()
  end

  def background(code, text) do
    IO.ANSI.color_background(code) <> text <> IO.ANSI.reset()
  end
end
