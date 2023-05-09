defmodule MultiplayerFrameWeb.RoomLobbyLive do
  use MultiplayerFrameWeb, :live_view
  alias MultiplayerFrame.{RoomServer, RoomSupervisor, Utils}

  def mount(_, session, socket) do
    socket =
      socket
      |> assign_from_session(session)
      |> assign(:loading, true)
      |> assign(:players, [])
      |> assign(host_id: nil)
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

      {:ok, {host_id, players}} ->
        socket
        |> assign(players: Map.values(players))
        |> assign(host_id: host_id)
        |> assign(loading: false)
    end
  end

  defp join_room(socket, _, _), do: socket

  def render(assigns) do
    ~H"""
    <%= if assigns.loading do %>
      <div class="flex p-4 justify-center">Joining room <%=assigns.room_code %>... </div>
    <% else %>
      <div class="p-4 flex flex-row gap-4">
        <div class = "p-4 bg-gray-300 border-solid rounded-md flex-0" >
          <h3 class="font-bold"> Lobby Code </h3>
          <div class="text-2xl font-bold"> <%= assigns.room_code %> </div>

          <h3 class="font-bold pt-4"> Players </h3>
          <ul class="list-style-bullet">
            <%= for player <- assigns.players do %>
              <.player is_host?={assigns.host_id == player.id} i_am_host?={assigns.host_id == assigns.player_id} player={player} />
            <% end %>
          </ul>
        </div>

        <div class = "text-gray-500 bg-gray-300 border-solid rounded-md flex-1 flex justify-center items-center" >
          Activity Content
        </div>
      </div>
    <% end %>
    """
  end

  def player(assigns) do
    ~H"""
      <li class = "flex gap-4">
        <p>
          <%= assigns.player.name %>
          <%= if assigns.is_host? do %> <span class="text-orange-600"> (Host) </span> <% end %>
        </p>
        <%= if assigns.i_am_host? && !assigns.is_host? do %>
          <button phx-click="kick_player" phx-value-player={assigns.player.id} class="underline hover:opacity-70"> Kick </button>
        <% end %>
      </li>
    """
  end

  def handle_event("kick_player", %{"player" => player}, socket) do
    RoomServer.kick_player(socket.assigns.room_code, socket.assigns.player_id, player)
    noreply(socket)
  end

  def handle_info({"server:player_joins", %{id: id} = player}, socket)
      when id != socket.assigns.player_id do
    socket
    |> assign(players: [player | socket.assigns.players])
    |> noreply()
  end

  def handle_info("server:kicked", socket) do
    socket
    |> Utils.redirect_to_root(:kicked)
    |> noreply()
  end

  def handle_info({"server:player_leaves", {players, new_host_id}}, socket) do
    socket
    |> assign(players: Map.values(players))
    |> assign(host_id: new_host_id)
    |> noreply()
  end

  def handle_info(_, socket), do: {:noreply, socket}

  defp noreply(socket), do: {:noreply, socket}
end
