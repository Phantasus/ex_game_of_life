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

defmodule GamOfLife.MatrixTest do
  use ExUnit.Case, async: true

  @used_module GameOfLife.Matrix
  
  describe "build_row" do
    test "when empty" do
      assert {:array, 0, 0, :undefined, 10}  == @used_module.build_row(0, 0, fn _x, _y -> 0 end)
    end

    test "one element" do
      expected = {
        :array,
        1,
        0,
        :undefined,
        {0, :undefined, :undefined, :undefined,
         :undefined, :undefined, :undefined, :undefined, :undefined, :undefined}
      }
      assert expected == @used_module.build_row(1, 0, fn _x, _y -> 0 end)
    end

    test "two elements" do
      expected =  {
        :array, 2, 0,
        :undefined, {0, 0, :undefined, :undefined, :undefined, :undefined,
                     :undefined, :undefined, :undefined, :undefined}
      }
      assert expected == @used_module.build_row(2, 0, fn _x, _y -> 0 end)
    end

    test "three elements" do
      expected =  {
        :array, 3, 0,
        :undefined, {0, 0, 0, :undefined, :undefined, :undefined,
                     :undefined, :undefined, :undefined, :undefined}
      }
      assert expected == @used_module.build_row(3, 0, fn _x, _y -> 0 end)
    end

    test "five elements" do
      expected =  {
        :array, 5, 0,
        :undefined, {0, 0, 0, 0, 0, :undefined,
                     :undefined, :undefined, :undefined, :undefined}
      }
      
      assert expected == @used_module.build_row(5, 0, fn _x, _y -> 0 end)
    end
  end

  describe "build_matrix" do
    test "when empty" do
      matrix = @used_module.build_matrix(%{width: 0, height: 0, cell_builder: fn _x, _y -> 0 end})
      
      assert [] == @used_module.to_list(matrix)
    end

    test "when one item" do
      expected = [
        [0]
      ]
      matrix = @used_module.build_matrix(%{width: 1, height: 1, cell_builder: fn _x, _y -> 0 end})
      
      assert expected == @used_module.to_list(matrix)
    end

    test "when one row" do
      expected = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      ]
      matrix = @used_module.build_matrix(%{width: 10, height: 1, cell_builder: fn _x, _y -> 0 end})
      assert expected == @used_module.to_list(matrix)
    end

    test "when three rows" do
      expected = [
        [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0]
      ]
      matrix = @used_module.build_matrix(%{width: 3, height: 3, cell_builder: fn _x, _y -> 0 end})
      assert expected == @used_module.to_list(matrix)
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

      new_matrix = @used_module.apply_to_cells(matrix, fn {_x, _y}, cell -> cell + 1 end)
      assert expected == @used_module.to_list(new_matrix)
    end
  end

end
