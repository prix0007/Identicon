defmodule Identicon do
  @moduledoc """
    A Elixir Project to build a identicon based on a string input.
  """

 def main(input) do
  input
  |> Identicon.hash_input()
  |> Identicon.pick_color()
  |> Identicon.build_grid()
 end

 def hash_input(input) do
  hex = :crypto.hash(:md5, input) |> :binary.bin_to_list()
  %Identicon.Image{hex: hex}
 end

 def pick_color(%Identicon.Image{hex: [r, g, b | _rest ]} = image) do
  %Identicon.Image{image | color: { r, g, b }}
 end

 def build_grid(%Identicon.Image{hex: hex}) do
  hex
  |> Enum.chunk_every(3)
  |> Enum.map(&Identicon.mirror_row/1)
  |> List.flatten()
 end

 def mirror_row(row) do
  case row do
    [a, b, _c] -> row ++ [b, a]
    _ -> row
  end
 end

end
