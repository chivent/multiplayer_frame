# MultiplayerFrame

A frame for basic multiplayer party rooms written in Elixir, with each created room supporting up to 4 users.

## How it Works

- Hosts can easily create a room with a random generated room-code.
- Other players can join existing rooms using the same room-code.
- Each browser may only join the same room once (aka using incognito would count as a different user.)
- The room will automatically shut down once no players are left.

## Host Actions

- Hosts can kick players
- Host status will automatically swap to the next available player if host leaves/disconnects

# Instructions

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
