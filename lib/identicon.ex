defmodule Identicon do
  def create(str) do
    str
    |> hash_str()
    |> Identicon.Image.with_hex()
    |> pick_color()
    |> make_grid()
    |> filter_odd_squares()
  end

  @doc """
    Filter out odd squares from the `grid`

    ## Examples

      iex> Identicon.filter_odd_squares(
      ...>  %Identicon.Image{
      ...>    grid: [
      ...>      {1, 0},
      ...>      {2, 1},
      ...>      {3, 2},
      ...>      {2, 3},
      ...>      {1, 4},
      ...>      {4, 5},
      ...>      {5, 6},
      ...>      {6, 7},
      ...>      {5, 8},
      ...>      {4, 9}
      ...>    ]
      ...>  }
      ...>)
      %Identicon.Image{
          grid: [
            {2, 1},
            {2, 3},
            {4, 5},
            {6, 7},
            {4, 9}
          ]
        }
  """
  @spec filter_odd_squares(image :: Identicon.Image.t()) :: Identicon.Image.t()
  def filter_odd_squares(image = %Identicon.Image{grid: grid}) do
    image
    |> Identicon.Image.with_grid(
      grid
      |> Enum.filter(fn {x, _} -> Bitwise.band(x, 1) == 0 end)
    )
  end

  @doc """
    Updates `grid` field of `Identicon.Image` struct.
    Use `hex` field to create the `grid`

    ## Examples

        iex> Identicon.make_grid(%Identicon.Image{hex: [1, 2, 3, 4]})
        %Identicon.Image{hex: [1, 2, 3, 4], grid: [{1, 0}, {2, 1}, {3, 2}, {2, 3}, {1, 4}]}
        iex> Identicon.make_grid(%Identicon.Image{hex: [1, 2, 3, 4, 5, 6]})
        %Identicon.Image{
          hex: [1, 2, 3, 4, 5, 6],
          grid: [
            {1, 0},
            {2, 1},
            {3, 2},
            {2, 3},
            {1, 4},
            {4, 5},
            {5, 6},
            {6, 7},
            {5, 8},
            {4, 9}
          ]
        }
        iex> Identicon.make_grid(%Identicon.Image{hex: [1, 2, 3, 4, 5, 6, 7, 8]})
        %Identicon.Image{
          hex: [1, 2, 3, 4, 5, 6, 7, 8],
          grid: [
            {1, 0},
            {2, 1},
            {3, 2},
            {2, 3},
            {1, 4},
            {4, 5},
            {5, 6},
            {6, 7},
            {5, 8},
            {4, 9}
          ]
        }
        iex> Identicon.make_grid(%Identicon.Image{hex: [1, 2, 3, 4, 5, 6, 7, 8, 9]})
        %Identicon.Image{
          hex: [1, 2, 3, 4, 5, 6, 7, 8, 9],
          grid: [
            {1, 0},
            {2, 1},
            {3, 2},
            {2, 3},
            {1, 4},
            {4, 5},
            {5, 6},
            {6, 7},
            {5, 8},
            {4, 9},
            {7, 10},
            {8, 11},
            {9, 12},
            {8, 13},
            {7, 14}
          ]
        }
  """
  @spec make_grid(image :: Identicon.Image.t()) :: Identicon.Image.t()
  def make_grid(image = %Identicon.Image{hex: hex}) do
    image
    |> Identicon.Image.with_grid(
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.flat_map(&mirror_row/1)
      |> Enum.with_index()
    )
  end

  @doc """
    Mirrors a list of integers, making the last element as pivot

    ## Examples

      iex> Identicon.mirror_row([])
      []
      iex> Identicon.mirror_row([1, 2])
      [1, 2, 1]
      iex> Identicon.mirror_row([1, 2, 3])
      [1, 2, 3, 2, 1]
  """
  @spec mirror_row(row :: list(integer())) :: list(integer())
  def mirror_row(row) do
    row ++ (row |> Enum.reverse() |> Enum.drop(1))
  end

  @doc """
    Updates `color` field of `Identicon.Image` struct.
    Uses first 3 values of the `hex` field for `color`

    ## Examples

        iex> Identicon.pick_color(%Identicon.Image{hex: [1, 2, 3, 4]})
        %Identicon.Image{hex: [1, 2, 3, 4], color: {1, 2, 3}}
  """
  @spec pick_color(image :: Identicon.Image.t()) :: Identicon.Image.t()
  def pick_color(image = %Identicon.Image{hex: [r, g, b | _]}) when length(image.hex) >= 3 do
    image |> Identicon.Image.with_color({r, g, b})
  end

  @doc """
    Converts the given string to a "unique" list of integers

    ## Examples

        iex> Identicon.hash_str("apple")
        [31, 56, 112, 190, 39, 79, 108, 73, 179, 227, 26, 12, 103, 40, 149, 127]
        iex> Identicon.hash_str("ball")
        [122, 16, 234, 27, 155, 40, 114, 218, 159, 55, 80, 2, 196, 77, 223, 206]
  """
  @spec hash_str(str :: charlist()) :: list(integer())
  def hash_str(str) do
    :crypto.hash(:md5, str) |> :binary.bin_to_list()
  end
end
