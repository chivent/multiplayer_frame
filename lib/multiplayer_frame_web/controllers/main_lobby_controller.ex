defmodule MultiplayerFrameWeb.MainLobbyController do
  use MultiplayerFrameWeb, :controller
  alias MultiplayerFrame.Player
  alias MultiplayerFrame.RoomSupervisor

  def index(conn, _) do
    render(conn, "index.html")
  end

  # TODO: Account for blank username
  def join(conn, %{"player_info" => %{"name" => name, "room_code" => code}}) when code != "" do
    conn
    |> put_session(:player, Player.create_player(name))
    |> put_session(:room_code, code)
    |> redirect(to: Routes.room_lobby_path(conn, :index))
  end

  @spec join(Plug.Conn.t(), any) :: Plug.Conn.t()
  def join(conn, %{"player_info" => %{"name" => name}}) do
    player = Player.create_player(name)
    {:ok, room_code} = RoomSupervisor.create_room(player)

    conn
    |> put_session(:player, player)
    |> put_session(:room_code, room_code)
    |> redirect(to: Routes.room_lobby_path(conn, :index))
  end
end
