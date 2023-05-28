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

defmodule GameOfLife.Cell do
  use Agent

  def start_link({x, y}) do
    state = %{
      x: x,
      y: y,
      state: :alive
    }
    
    Agent.start_link(fn -> state end)
  end

  def shutdown_cell!(pid) when is_pid(pid) do
    Process.exit(pid, :normal)
  end

  def get_state(pid) when is_pid(pid) do
    Agent.get(pid, fn state -> state.state end)
  end

  def get_coordinate(pid) when is_pid(pid) do
    Agent.get(pid, fn state -> {state.x, state.y} end)
  end

  def change_state!(pid, new_state) do
    Agent.update(pid, fn state -> Map.put(state, :state, new_state) end)
  end

  def live_on!(pid) do
    # do nothing
  end
end
