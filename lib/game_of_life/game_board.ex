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

defmodule GameOfLife.GameBoard do
  use Agent
  
  def start_link(config) do
    matrix = build_matrix(build_matrix_config(config))

    state = %{
      matrix: matrix,
      width: config.width,
      height: config.height
    }
    
    Agent.start_link(fn -> state end, name: __MODULE__)
  end

  def build_matrix_config(config) do
    %{
      width: config.width,
      height: config.height,
      cell_builder: fn x, y -> {:ok, pid} = GameOfLife.Cell.start_link({x, y}); pid end
    }
  end

  def shutdown_matrix!(matrix) do
    for row <- matrix do
      shutdown_row!(row)
    end
  end

  def shutdown_row!(row) do
    for cell <- row do
      shutdown_cell!(cell)
    end
  end

  def shutdown_cell!(pid) when is_pid(pid) do
    GameOfLife.Cell.shutdown_cell!(pid)
  end

  @doc "Returns a new matrix"
  def build_matrix(config) do
    width  = config.width
    height = config.height
    builder = config.cell_builder
    
    cond do
      height == 0 -> []
      height < 0 -> raise("height negative")
      width < 0 -> raise("width negative")
      true ->
        for column <- 0 .. (height - 1) do
          build_row(width, column, builder)
          |> Enum.reverse()
        end
    end
  end

  @doc "Helper for building matrix rows"
  def build_row(0, _row_y, _lambda) do
    []
  end

  def build_row(row_length, row_y, lambda) do
    value = lambda.(row_length - 1, row_y)
    [value | build_row(row_length - 1, row_y, lambda)]
  end

  @doc "Applies the given `cell_fn` to all cell elements of the board matrix"
  def apply_to_cells(matrix, cell_fn) do
    for row <- matrix do
      for cell <- row do
        cell_fn.(cell)
      end
    end
  end

  @doc "Returns the states of the cells"
  def get_cell_states() do
    getter = fn state ->
      new_cells = state.matrix
      |> apply_to_cells(fn cell -> GameOfLife.Cell.get_state(cell) end)

      {:ok, new_cells}
    end
    
    Agent.get(__MODULE__, getter)
  end

  @doc "Returns the coordinates `{x, y}` of the stored cells"
  def get_cell_coordinates() do
    getter = fn state ->
      new_cells = state.matrix
      |> apply_to_cells(fn cell -> GameOfLife.Cell.get_coordinate(cell) end)

      {:ok, new_cells}
    end
    
    Agent.get(__MODULE__, getter)
  end

  @doc "Returns the pids of the cells as a matrix"
  def get_cell_pids() do
    getter = fn state ->
      new_cells = state.matrix
      |> apply_to_cells(fn cell -> cell end)

      {:ok, new_cells}
    end
    
    Agent.get(__MODULE__, getter)
  end

  @doc "Returns the cell `pid` by their `{x, y}` coordinates"
  def get_cell({x, y}) do
    getter = fn state ->
      cell = Enum.at(Enum.at(state.matrix, y), x)

      {:ok, cell}
    end
    
    Agent.get(__MODULE__, getter)
  end

  @doc "Returns the width of the gameboard"
  def get_board_width() do
    Agent.get(__MODULE__, fn state -> state.width end)
  end

  @doc "Returns the height of the gameboard"
  def get_board_height() do
    Agent.get(__MODULE__, fn state -> state.height end)
  end

  @doc "Returns the top neighbour of a cell"
  def get_top_neighbours({x, y}) do
    width = get_board_width()
    height = get_board_height()
    
    new_x0 = rem(x - 1, width)
    new_y0 = rem(y - 1, height)

    new_x1 = rem(x, width)
    new_y1 = rem(y - 1, height)

    new_x2 = rem(x + 1, width)
    new_y2 = rem(y - 1, height)

    {:ok, pid0} = get_cell({new_x0, new_y0})
    {:ok, pid1} = get_cell({new_x1, new_y1})
    {:ok, pid2} = get_cell({new_x2, new_y2})

    {:ok, [pid0, pid1, pid2]}
  end

  @doc "Returns the bottom neighbour of a cell"
  def get_bottom_neighbours({x, y}) do
    width  = get_board_width()
    height = get_board_height()

    new_x0 = rem(x - 1, width)
    new_y0 = rem(y + 1, height)

    new_x1 = rem(x, width)
    new_y1 = rem(y + 1, height)

    new_x2 = rem(x + 1, width)
    new_y2 = rem(y + 1, height)

    {:ok, pid0} = get_cell({new_x0, new_y0})
    {:ok, pid1} = get_cell({new_x1, new_y1})
    {:ok, pid2} = get_cell({new_x2, new_y2})

    {:ok, [pid0, pid1, pid2]}
  end

  @doc "Returns the left neighbour of a cell"
  def get_left_neighbour({x, y}) do
    width  = get_board_width()
    height = get_board_height()

    new_x = rem(x - 1, width)
    new_y = rem(y, height)

    get_cell({new_x, new_y})
  end

  @doc "Returns the right neighbour of a cell"
  def get_right_neighbour({x, y}) do
    width  = get_board_width()
    height = get_board_height()

    new_x = rem(x + 1, width)
    new_y = rem(y, height)

    get_cell({new_x, new_y})
  end

  @doc "Kills (= make it dead) the given cell at the given coordinates"
  def kill_cell!(position) do
    {:ok, pid} = get_cell(position)

    GameOfLife.Cell.change_state!(pid, :dead)
    :ok
  end

  @doc "Returns the neighbours of the given cell"
  def get_neighbours(position) do
    {:ok, top_cells}    = get_top_neighbours(position)
    {:ok, left_cell}    = get_left_neighbour(position)
    {:ok, right_cell}   = get_right_neighbour(position)
    {:ok, bottom_cells} = get_bottom_neighbours(position)
    
    cells = top_cells ++ [left_cell, right_cell] ++ bottom_cells
    
    {:ok, cells}
  end

  def count_cell_states(cells, state) do
    Enum.map(cells, &GameOfLife.Cell.get_state/1)
    |> Enum.reduce(0, fn item, acc -> if item == state, do: acc + 1, else: acc end)
  end
  
  @doc "Applies the game of life rules to the given cell"
  def apply_rules_to(position) do
    {:ok, neighbours} = get_neighbours(position)

    {:ok, cell} = get_cell(position)
    state       = GameOfLife.Cell.get_state(cell)
    alive_count = count_cell_states(neighbours, :alive)

    cond do
      state == :alive and alive_count < 2 -> # rule1
        GameOfLife.Cell.change_state!(cell, :dead)
      state == :alive and (alive_count in [2,3]) -> # rule2
        # lives on, do nothing
        GameOfLife.Cell.live_on!(cell)
      state == :alive and (alive_count > 3) ->
        GameOfLife.Cell.change_state!(cell, :dead) # rule3
      state == :dead and (alive_count == 3) ->
        GameOfLife.Cell.change_state!(cell, :alive) # rule4
    end
    :ok
  end
end
