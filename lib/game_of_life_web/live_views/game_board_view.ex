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

defmodule GameOfLifeWeb.GameBoardView do
  use GameOfLifeWeb, :live_view
  import Phoenix.Component

  def start_board(width, height) do
    case GameOfLife.GameBoard.start_link(%{width: width, height: height}) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end

  def mount(_params, session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :update, 2000)
    end
    
    height = 200
    width = 200
    pixelsize = 2

    {:ok, pid} = start_board(width, height)
    GameOfLife.GameBoard.clear_board!()
    GameOfLife.GameBoard.seed_board!()

    GameOfLife.GameBoard.apply_rules!()
    
    {:ok, specs} = GameOfLife.GameBoard.get_draw_specs()

    new_assigns = assign(socket, :draw_specs, specs)
    |> assign(:canvas_height, pixelsize * height)
    |> assign(:canvas_width, pixelsize * width)
    |> assign(:pixel_size, pixelsize)
    |> assign(:gameboard_pid, pid)
    |> assign(:generation, 1)
    |> assign(:render_time, 0)
    
    {:ok, new_assigns}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 2000)
    time1 = DateTime.utc_now()
    GameOfLife.GameBoard.apply_rules!()

    {:ok, specs} = GameOfLife.GameBoard.get_draw_specs()
    time2 = DateTime.utc_now()
    diff  = DateTime.diff(time2, time1, :millisecond)

    new_assigns = assign(socket, :generation, socket.assigns.generation + 1)
    |> assign(:render_time, diff)
    
    {:noreply, push_event(new_assigns, "redraw", %{"specs": specs})}
  end
end
