# GameOfLife

This is a small hacking exercise for fun in Elixir to implement a version of the
Game of Life. It's a naive implementation, which uses the BEAMs ability
to just run a ton of processes. So each cell of the Game is a process,
which holds the state of the cell, that's not efficient and not a
best practice to implement the game, but just an implementation to
be for fun.

# Startup
To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

# License

GNU AFFERO GENERAL PUBLIC LICENSE version 3

>    Game of Life - is a small hacking exercise of the Game of Life in Elixir 
>    Copyright (C) 2023 Josef Philip Bernhart
>
>    This program is free software: you can redistribute it and/or modify
>    it under the terms of the GNU Affero General Public License as published by
>    the Free Software Foundation, either version 3 of the License, or
>    (at your option) any later version.
>
>    This program is distributed in the hope that it will be useful,
>    but WITHOUT ANY WARRANTY; without even the implied warranty of
>    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>    GNU Affero General Public License for more details.
>
>    You should have received a copy of the GNU Affero General Public License
>    along with this program.  If not, see <https://www.gnu.org/licenses/>.
