defmodule MultiplayerFrame.RoomServer do
  use GenServer
  alias MultiplayerFrame.{Player, RoomSupervisor}

  @impl true
  def init(args) do
    {:ok, args}
  end

  def start_link({room_code, %Player{} = player}) do
    GenServer.start_link(
      __MODULE__,
      %{
        room_code: room_code,
        host: player.id,
        players: %{},
        player_pids: %{}
      },
      name: name(room_code)
    )
  end

  def name(code), do: {:global, code}

  ## Player Actions
  def player_joins(room_code, pid, player) do
    GenServer.call(
      name(room_code),
      {"player_joins", {pid, player}}
    )
  end

  def kick_player(room_code, caller_id, player) do
    GenServer.cast(
      name(room_code),
      {"kick_player", {caller_id, player}}
    )
  end

  def check_room_capacity(room_code) do
    GenServer.call(name(room_code), "check_room_capacity")
  end

  @impl true
  def handle_call({"player_joins", {pid, player}}, _, state) do
    if get_in(state, [:players, player.id]) do
      {:reply, {:error, :already_in_room}, state}
    else
      Process.monitor(pid)

      Phoenix.PubSub.broadcast(
        MultiplayerFrame.PubSub,
        "rooms:#{state.room_code}",
        {"server:player_joins", player}
      )

      state =
        state
        |> put_in([:players, player.id], player)
        |> put_in([:player_pids, pid], player.id)

      {:reply, {:ok, {state.host, state.players}}, state}
    end
  end

  @impl true
  def handle_call("check_room_capacity", _, state) do
    player_count = state.players |> Map.keys() |> length()

    {:reply, player_count < 4, state}
  end

  @impl true
  def handle_cast({"kick_player", {caller_id, player}}, state) do
    if caller_id == state.host do
      {pid, _} = Enum.find(state.player_pids, fn {_pid, id} -> id == player end)
      send(pid, "server:kicked")
    end

    {:noreply, state}
  end

  @impl true
  def handle_info({"player_leaves", {pid, id}}, state) do
    state =
      state
      |> update_in([:players], &Map.delete(&1, id))
      |> update_in([:player_pids], &Map.delete(&1, pid))

    players_left = get_in(state, [:players])

    if Map.keys(players_left) |> length() < 1 do
      RoomSupervisor.close_room(state.room_code)
      {:noreply, state}
    else
      new_host = Map.keys(state.players) |> List.first()

      Phoenix.PubSub.broadcast(
        MultiplayerFrame.PubSub,
        "rooms:#{state.room_code}",
        {"server:player_leaves", {players_left, new_host}}
      )

      {:noreply, Map.put(state, :host, new_host)}
    end
  end

  @impl true
  def handle_info({:DOWN, _ref, _, pid, _}, state) do
    player_id = get_in(state, [:player_pids, pid])
    send(self(), {"player_leaves", {pid, player_id}})

    {:noreply, state}
  end
end
