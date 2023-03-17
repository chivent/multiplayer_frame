defmodule MultiplayerFrameWeb.RoomLobbyLive do
  use MultiplayerFrameWeb, :live_view
  alias MultiplayerFrame.{RoomServer, RoomSupervisor, Utils}

  def mount(_, session, socket) do
    socket =
      socket
      |> assign_from_session(session)
      |> assign(:loading, true)
      |> assign(:players, [])
      |> assign(host: nil)
      |> join_room(session, connected?(socket))

    {:ok, socket}
  end

  defp assign_from_session(socket, %{"player" => player, "room_code" => room_code}) do
    socket
    |> assign(:room_code, room_code)
    |> assign(:player_id, player.id)
  end

  defp join_room(%{assigns: %{room_code: room_code}} = socket, session, true) do
    if RoomSupervisor.room_exists?(room_code) do
      join_room(socket, session, :room_open)
    else
      Utils.redirect_to_root(socket, :room_closed)
    end
  end

  defp join_room(socket, %{"player" => player}, :room_open) do
    room_code = socket.assigns.room_code
    Phoenix.PubSub.subscribe(MultiplayerFrame.PubSub, "rooms:#{room_code}")

    case RoomServer.player_joins(room_code, self(), player) do
      {:error, :already_in_room} ->
        Utils.redirect_to_root(socket, :already_in_room)

      {:ok, {host, players}} ->
        socket
        |> assign(players: Map.values(players))
        |> assign(host: host)
        |> assign(loading: false)
    end
  end

  defp join_room(socket, _, _), do: socket

  def render(assigns) do
    ~H"""
    <%= if assigns.loading do %>
      Joining room <%=assigns.room_code %>...
    <% else %>
      <div class = "p-4 bg-gray-300 border-solid rounded-md w-full" >
        <div class="text-lg font-bold"> <%= assigns.room_code %> </div>
        <ul class="list-style-bullet">
          <%= for player <- assigns.players do %>
            <li class = "flex gap-4">
              <p> <%= player.name %> <%= if assigns.host == player.id, do: "(Host)" %></p>
              <%= if assigns.host == assigns.player_id && assigns.host != player.id do %>
                <button phx-click="kick_player" phx-value-player={player.id}> Kick </button>
              <% end %>
            </li>
          <% end %>
        </ul>
      </div>
    <% end %>
    """
  end

  def handle_event("kick_player", %{"player" => player}, socket) do
    RoomServer.kick_player(socket.assigns.room_code, socket.assigns.player_id, player)
    {:noreply, socket}
  end

  def handle_info({"server:player_joins", %{id: id} = player}, socket)
      when id != socket.assigns.player_id do
    {:noreply, assign(socket, players: [player | socket.assigns.players])}
  end

  def handle_info("server:kicked", socket) do
    {:noreply, Utils.redirect_to_root(socket, :kicked)}
  end

  def handle_info({"server:player_leaves", players}, socket) do
    {:noreply, assign(socket, players: Map.values(players))}
  end

  def handle_info(_, socket), do: {:noreply, socket}
end
