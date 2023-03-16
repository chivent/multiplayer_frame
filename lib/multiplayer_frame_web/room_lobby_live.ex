defmodule MultiplayerFrameWeb.RoomLobbyLive do
  use MultiplayerFrameWeb, :live_view
  alias MultiplayerFrame.RoomServer

  # TODO: Kick if no player name/id
  def mount(%{"id" => id}, session, socket) do
    socket =
      socket
      |> assign(:room_code, id)
      |> assign(:players, [])
      |> join_room(session, connected?(socket))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <div>
        <button phx-click="mock_call">Mock Check</button>
        <%= for player <- assigns.players do %>
          <div> <%= player.name %> </div>
        <% end %>
      </div>
    """
  end

  def handle_info({"server:player_joins", %{id: id} = player}, socket)
      when id != socket.assigns.player_id do
    {:noreply, assign(socket, players: [player | socket.assigns.players])}
  end

  def handle_info({"server:player_leaves", players}, socket) do
    {:noreply, assign(socket, players: Map.values(players))}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  defp join_room(socket, %{"player" => player}, connected) when connected do
    room_code = socket.assigns.room_code
    Phoenix.PubSub.subscribe(MultiplayerFrame.PubSub, "rooms:#{room_code}")

    socket = assign(socket, player_id: player.id)

    case RoomServer.player_joins(room_code, self(), player) do
      players when is_map(players) ->
        assign(socket, players: Map.values(players))

      _ ->
        assign(socket, players: [])
    end
  end

  defp join_room(socket, _, _), do: socket
end
