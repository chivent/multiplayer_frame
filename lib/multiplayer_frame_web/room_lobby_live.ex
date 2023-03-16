defmodule MultiplayerFrameWeb.RoomLobbyLive do
  use MultiplayerFrameWeb, :live_view
  alias MultiplayerFrame.{RoomServer, RoomSupervisor}

  def mount(_, session, socket) do
    socket =
      socket
      |> assign_from_session(session)
      |> assign(:players, [])
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
      join_room(socket, session, :room_closed)
    end
  end

  defp join_room(socket, %{"player" => player}, :room_open) do
    room_code = socket.assigns.room_code
    Phoenix.PubSub.subscribe(MultiplayerFrame.PubSub, "rooms:#{room_code}")

    case RoomServer.player_joins(room_code, self(), player) do
      players when is_map(players) ->
        assign(socket, players: Map.values(players))

      _ ->
        assign(socket, players: [])
    end
  end

  defp join_room(socket, _, :room_closed) do
    socket
    |> put_flash(:error, "The room you're looking for does not exist.")
    |> redirect(to: Routes.root_path(socket, :index))
  end

  defp join_room(socket, _, false), do: socket

  def render(assigns) do
    ~H"""
      <div>
        <div> <%= assigns.room_code %> </div>
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
end
