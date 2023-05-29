# ex_game_of_life - an implementation of Conway's Game of Life for fun
# Copyright (C) 2023 Josef Philip Bernhart
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.

defmodule GameOfLife.Matrix do
  @doc "Returns a new matrix"
  def build_matrix(config) do
    width   = config.width
    height  = config.height
    builder = config.cell_builder
    
    cond do
      height == 0 -> :array.new(0)
      height < 0 -> raise("height negative")
      width < 0 -> raise("width negative")
      true ->
        0 .. (height - 1)
        |> Enum.to_list()
        |> Enum.map(fn y -> build_row(width, y, builder) end)
        |> :array.from_list()
        |> :array.fix()
    end
  end

  @doc "Helper for building matrix rows"
  def build_row(0, _row_y, _lambda) do
    :array.new(0)
  end

  def build_row(row_length, row_y, lambda) do
    Range.new(0, (row_length - 1))
    |> Enum.to_list()
    |> Enum.map(fn column -> lambda.(column, row_y) end)
    |> :array.from_list()
    |> :array.fix()
  end

  @doc """
  Converts the internal matrix representation, which uses arrays to
  something more readable
  """
  def to_list(matrix) do
    :array.to_list(matrix)
    |> Enum.map(fn row -> :array.to_list(row) end)
  end
  
  @doc "Applies the given `cell_fn` to all cell elements of the board matrix"
  def apply_to_cells(matrix, cell_fn) do
    :array.map(
      fn y, row ->
        :array.map(fn x, cell -> cell_fn.({x, y}, cell) end, row)
      end,
      matrix
    )
  end

  @doc "Returns the cell value at the given position"
  def get(matrix, {x, y}) when is_integer(x) and is_integer(y) do
    height = :array.size(matrix)
    row    = :array.get(Integer.mod(y, height), matrix)
    width  = :array.size(row)
    
    :array.get(Integer.mod(x, width), row)
  end

  @doc "Maps the given `row_fn` to all the rows in the matrix"
  def map_rows(matrix, row_fn) do
    :array.map(row_fn, matrix)
  end
end
