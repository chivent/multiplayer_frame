# MultiplayerFrame

Frame for basic multiplayer room creation, with each room supporting up to of 4 players

- Hosts can easily create a room with a random generated room-code.
- Other players can join existing rooms using the same room-code.
- Hosts can kick players, and host status will automatically swap to the next available player if host leaves
- Can probably support up to 10 players if limit is updated, but will remain at a small scale till larger changes are applied.

## Instructions

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
