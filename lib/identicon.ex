defmodule Identicon do
  @moduledoc """
    A Elixir Project to build a identicon based on a string input.
  """

 def main(input) do
  input
  |> Identicon.hash_input
  |> Identicon.pick_color
  |> Identicon.build_grid
  |> Identicon.filter_odd_squares
  |> Identicon.build_pixel_map
  |> Identicon.draw_image
  |> Identicon.save_image(input)
 end

 def hash_input(input) do
  hex = :crypto.hash(:md5, input) |> :binary.bin_to_list()
  %Identicon.Image{hex: hex}
 end

 def pick_color(%Identicon.Image{hex: [r, g, b | _rest ]} = image) do
  %Identicon.Image{image | color: { r, g, b }}
 end

 def build_grid(%Identicon.Image{hex: hex} = image) do
  grid =
    hex
    |> Enum.chunk_every(3)
    |> Enum.map(&Identicon.mirror_row/1)
    |> List.flatten()
    |> Enum.with_index()

  %Identicon.Image{image | grid: grid}
 end

 def mirror_row(row) do
  case row do
    [a, b, _c] -> row ++ [b, a]
    _ -> row
  end
 end

 def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
  %Identicon.Image{
    image |
    grid: Enum.filter(grid, fn({x, _index}) -> rem(x, 2) == 0 end)
  }
 end

 def build_pixel_map(%Identicon.Image{grid: grid} = image) do
  pixel_map = Enum.map(
    grid, fn({_code, index}) ->
      h= rem(index, 5) * 50
      v = div(index, 5) * 50
      top_left = {h, v}
      bottom_right= {h+50, v+50}
      {top_left, bottom_right}
    end
  )
  %Identicon.Image{image | pixel_map: pixel_map}
 end

 def draw_image(%Identicon.Image{pixel_map: pixel_map, color: color}) do
  image = :egd.create(250,250)
  fill = :egd.color(color)

  Enum.each pixel_map, fn({start, stop}) ->
    :egd.filledRectangle(image, start, stop, fill)
  end

  :egd.render(image)

 end

 def save_image(image, filename) do
  File.write("#{filename}.png", image)
 end

end
