# MultiplayerFrame

A simple frame for multiplayer party rooms written in Elixir, with each created room supporting up to 4 users.

![image](https://github.com/chivent/multiplayer_frame/assets/13724957/b91284a2-7c6c-4397-8af8-2582bc55be81)

## How it Works

- All players enter a username.
- A player creates a room with a random generated room-code.
- Other players can join the existing room using the same room-code.
- Each browser may only join the same room once.
- The room will automatically shut down once all players have left.

## Host Actions

- A player that creates the room is the host.
- Hosts can kick other players.
- Host status will automatically swap to the next available player if host leaves/disconnects/refreshes.

# Instructions

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
