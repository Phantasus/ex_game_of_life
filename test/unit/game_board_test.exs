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

defmodule GamOfLife.GameBoardTest do
  use ExUnit.Case, async: true

  @used_module GameOfLife.GameBoard
  
  test "build_row" do
    assert [] == @used_module.build_row(0, 0, fn _x, _y -> 0 end)
    assert [0] == @used_module.build_row(1, 0, fn _x, _y -> 0 end)
    assert [0, 0] == @used_module.build_row(2, 0, fn _x, _y -> 0 end)
    assert [0, 0, 0] == @used_module.build_row(3, 0, fn _x, _y -> 0 end)
    assert [0, 0, 0, 0, 0] == @used_module.build_row(5, 0, fn _x, _y -> 0 end)
  end

  describe "build_matrix" do
    test "when empty" do
      assert [] == @used_module.build_matrix(%{width: 0, height: 0, cell_builder: fn _x, _y -> 0 end})
    end

    test "when one item" do
      expected = [
        [0]
      ]
      
      assert expected == @used_module.build_matrix(%{width: 1, height: 1, cell_builder: fn _x, _y -> 0 end})
    end

    test "when one row" do
      expected = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      ]
      assert expected == @used_module.build_matrix(%{width: 10, height: 1, cell_builder: fn _x, _y -> 0 end})
    end

    test "when three rows" do
      expected = [
        [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0]
      ]
      assert expected == @used_module.build_matrix(%{width: 3, height: 3, cell_builder: fn _x, _y -> 0 end})
    end
  end

  describe "apply_to_cells" do
    test "when small matrix" do
      matrix = @used_module.build_matrix(%{width: 3, height: 3, cell_builder: fn _x, _y -> 0 end})
      expected = [
        [1, 1, 1],
        [1, 1, 1],
        [1, 1, 1]
      ]

      assert expected == @used_module.apply_to_cells(matrix, fn cell -> cell + 1 end)
    end
  end

  describe "get_cell_states/0" do
    test "small matrix" do
      {:ok, _pid} = @used_module.start_link(%{width: 3, height: 3})

      expected = [
        [:alive, :alive, :alive],
        [:alive, :alive, :alive],
        [:alive, :alive, :alive]
      ]

      assert {:ok, expected} == @used_module.get_cell_states()
    end
  end

  describe "get_cell_coordinates/0" do
    test "small matrix" do
      {:ok, _pid} = @used_module.start_link(%{width: 3, height: 3})

      expected = [
        [{0, 0},  {1, 0}, {2, 0}],
        [{0, 1},  {1, 1}, {2, 1}],
        [{0, 2},  {1, 2}, {2, 2}]
      ]

      assert {:ok, expected} == @used_module.get_cell_coordinates()
    end
  end

  describe "get_cell" do
    test "when small matrix" do
      {:ok, _pid} = @used_module.start_link(%{width: 3, height: 3})

      {:ok, pids} = @used_module.get_cell_pids()
      {:ok, cell0} = @used_module.get_cell({0, 0})
      
      assert is_pid(cell0)
      assert Enum.at(Enum.at(pids, 0), 0) == cell0

      {:ok, cell1} = @used_module.get_cell({2, 0})
      assert Enum.at(Enum.at(pids, 0), 2) == cell1
    end
  end

  describe "get_top_neighbours/1" do
    test "when small matrix, in the middle" do
      {:ok, _pid} = @used_module.start_link(%{width: 3, height: 3})

      {:ok, expected_cell0} = @used_module.get_cell({0, 0})
      assert is_pid(expected_cell0)

      {:ok, expected_cell1} = @used_module.get_cell({1, 0})
      assert is_pid(expected_cell1)

      {:ok, expected_cell2} = @used_module.get_cell({2, 0})
      assert is_pid(expected_cell2)

      {:ok, cells} = @used_module.get_top_neighbours({1, 1})
      assert [expected_cell0, expected_cell1, expected_cell2] == cells
    end
  end

  describe "get_bottom_neighbours/1" do
    test "when small matrix, in the middle" do
      {:ok, _pid} = @used_module.start_link(%{width: 3, height: 3})

      {:ok, expected_cell0} = @used_module.get_cell({0, 2})
      assert is_pid(expected_cell0)

      {:ok, expected_cell1} = @used_module.get_cell({1, 2})
      assert is_pid(expected_cell1)

      {:ok, expected_cell2} = @used_module.get_cell({2, 2})
      assert is_pid(expected_cell2)

      {:ok, cells} = @used_module.get_bottom_neighbours({1, 1})
      assert [expected_cell0, expected_cell1, expected_cell2] == cells
    end
  end
  
  describe "get_left_neighbour/1" do
    test "when small matrix, in the middle" do
      {:ok, _pid} = @used_module.start_link(%{width: 3, height: 3})

      {:ok, expected_cell} = @used_module.get_cell({0, 1})
      assert is_pid(expected_cell)

      {:ok, cell} = @used_module.get_left_neighbour({1, 1})
      assert expected_cell == cell
    end
    
    test "when small matrix, in the first position" do
      {:ok, _pid} = @used_module.start_link(%{width: 3, height: 3})

      {:ok, expected_cell} = @used_module.get_cell({2, 0})
      assert is_pid(expected_cell)

      {:ok, cell} = @used_module.get_left_neighbour({0, 0})
      assert expected_cell == cell
    end
  end

  describe "get_right_neighbour/1" do
    test "when small matrix, in the middle" do
      {:ok, _pid} = @used_module.start_link(%{width: 3, height: 3})

      {:ok, expected_cell} = @used_module.get_cell({2, 1})
      assert is_pid(expected_cell)

      {:ok, cell} = @used_module.get_right_neighbour({1, 1})
      assert expected_cell == cell
    end

    test "when small matrix, in the last position" do
      {:ok, _pid} = @used_module.start_link(%{width: 3, height: 3})

      {:ok, expected_cell} = @used_module.get_cell({0, 2})
      assert is_pid(expected_cell)

      {:ok, cell} = @used_module.get_right_neighbour({2, 2})
      assert expected_cell == cell
    end
  end

  describe "killing of cells" do
    test "when small matrix" do
      {:ok, _pid} = @used_module.start_link(%{width: 3, height: 3})

      assert :ok == @used_module.kill_cell!({1, 1})
      expected = [
        [:alive, :alive, :alive],
        [:alive, :dead,  :alive],
        [:alive, :alive, :alive]
      ]

      assert {:ok, expected} == @used_module.get_cell_states()
    end
  end

  describe "rule1 of game of life" do
    # rule1 of the game:
    # Any live cell with fewer than two live neighbours dies, as if by underpopulation. 
    test "when small matrix" do
      {:ok, _pid} = @used_module.start_link(%{width: 3, height: 3})

      assert :ok == @used_module.kill_cell!({0, 0})
      assert :ok == @used_module.kill_cell!({1, 0})
      assert :ok == @used_module.kill_cell!({2, 0})

      assert :ok == @used_module.kill_cell!({0, 1})
      assert :ok == @used_module.kill_cell!({2, 1})

      assert :ok == @used_module.kill_cell!({0, 2})
      assert :ok == @used_module.kill_cell!({2, 2})
      
      expected0 = [
        [:dead, :dead,  :dead],
        [:dead, :alive, :dead],
        [:dead, :alive, :dead]
      ]

      assert {:ok, expected0} == @used_module.get_cell_states()
      
      expected1 = [
        [:dead, :dead,  :dead],
        [:dead, :dead,  :dead],
        [:dead, :alive, :dead]
      ]

      assert :ok == @used_module.apply_rules_to({1, 1})
      assert {:ok, expected1} == @used_module.get_cell_states()
    end
  end

  describe "rule2 of game of life" do
    # rule2 of the game:
    # Any live cell with two or three live neighbours lives on to the next generation.
    test "when small matrix, when two live neighbours" do
      {:ok, _pid} = @used_module.start_link(%{width: 3, height: 3})

      assert :ok == @used_module.kill_cell!({0, 0})
      assert :ok == @used_module.kill_cell!({1, 0})
      assert :ok == @used_module.kill_cell!({2, 0})

      assert :ok == @used_module.kill_cell!({0, 1})

      assert :ok == @used_module.kill_cell!({0, 2})
      assert :ok == @used_module.kill_cell!({2, 2})
      
      expected0 = [
        [:dead, :dead,  :dead],
        [:dead, :alive, :alive],
        [:dead, :alive, :dead]
      ]

      assert {:ok, expected0} == @used_module.get_cell_states()
      
      expected1 = [
        [:dead, :dead,  :dead],
        [:dead, :alive, :alive],
        [:dead, :alive, :dead]
      ]

      assert :ok == @used_module.apply_rules_to({1, 1})
      assert {:ok, expected1} == @used_module.get_cell_states()
    end

    test "when small matrix, when three live neighbours" do
      {:ok, _pid} = @used_module.start_link(%{width: 3, height: 3})

      assert :ok == @used_module.kill_cell!({0, 0})
      assert :ok == @used_module.kill_cell!({1, 0})
      assert :ok == @used_module.kill_cell!({2, 0})

      assert :ok == @used_module.kill_cell!({0, 2})
      assert :ok == @used_module.kill_cell!({2, 2})
      
      expected0 = [
        [:dead,  :dead,  :dead],
        [:alive, :alive, :alive],
        [:dead,  :alive, :dead]
      ]

      assert {:ok, expected0} == @used_module.get_cell_states()
      
      expected1 = [
        [:dead,  :dead,  :dead],
        [:alive, :alive, :alive],
        [:dead,  :alive, :dead]
      ]

      assert :ok == @used_module.apply_rules_to({1, 1})
      assert {:ok, expected1} == @used_module.get_cell_states()
    end
  end

  describe "rule3 of game of life" do
    # rule3 of the game:
    # Any live cell with more than three live neighbours dies, as if by overpopulation.
    test "when small matrix, when three live neighbours" do
      {:ok, _pid} = @used_module.start_link(%{width: 3, height: 3})

      assert :ok == @used_module.kill_cell!({0, 0})
      assert :ok == @used_module.kill_cell!({2, 0})

      assert :ok == @used_module.kill_cell!({0, 2})
      assert :ok == @used_module.kill_cell!({2, 2})
      
      expected0 = [
        [:dead,  :alive, :dead],
        [:alive, :alive, :alive],
        [:dead,  :alive, :dead]
      ]

      assert {:ok, expected0} == @used_module.get_cell_states()
      
      expected1 = [
        [:dead,  :alive, :dead],
        [:alive, :dead,  :alive],
        [:dead,  :alive, :dead]
      ]

      assert :ok == @used_module.apply_rules_to({1, 1})
      assert {:ok, expected1} == @used_module.get_cell_states()
    end
  end

  describe "rule4 of game of life" do
    # rule4 of the game:
    # Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
    test "when small matrix, when three live neighbours" do
      {:ok, _pid} = @used_module.start_link(%{width: 3, height: 3})

      assert :ok == @used_module.kill_cell!({0, 0})
      assert :ok == @used_module.kill_cell!({1, 0})
      assert :ok == @used_module.kill_cell!({2, 0})

      assert :ok == @used_module.kill_cell!({1, 1})

      assert :ok == @used_module.kill_cell!({0, 2})
      assert :ok == @used_module.kill_cell!({2, 2})
      
      expected0 = [
        [:dead,  :dead,  :dead],
        [:alive, :dead,  :alive],
        [:dead,  :alive, :dead]
      ]

      assert {:ok, expected0} == @used_module.get_cell_states()
      
      expected1 = [
        [:dead,  :dead,  :dead],
        [:alive, :alive, :alive],
        [:dead,  :alive, :dead]
      ]

      assert :ok == @used_module.apply_rules_to({1, 1})
      assert {:ok, expected1} == @used_module.get_cell_states()
    end
  end
end
