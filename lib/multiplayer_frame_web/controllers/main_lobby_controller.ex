defmodule MultiplayerFrameWeb.MainLobbyController do
  use MultiplayerFrameWeb, :controller
  alias MultiplayerFrame.Player
  alias MultiplayerFrame.RoomSupervisor

  def index(conn, _) do
    render(conn, "index.html", player: get_session_player(conn))
  end

  def join(conn, %{"player_info" => %{"name" => ""}}) do
    conn
    |> put_flash(:error, "Please enter a username before joining any rooms.")
    |> render("index.html")
  end

  @spec join(Plug.Conn.t(), any) :: Plug.Conn.t()
  def join(conn, %{"player_info" => %{"name" => name, "room_code" => code}}) do
    player = create_player(conn, name)

    {:ok, room_code} =
      if code == "" do
        RoomSupervisor.create_room(player)
      else
        {:ok, code}
      end

    conn
    |> put_session(:player, player)
    |> put_session(:room_code, room_code)
    |> redirect(to: Routes.room_lobby_path(conn, :index))
  end

  defp get_session_player(conn) do
    Plug.Conn.get_session(conn, "player") || %Player{}
  end

  defp create_player(conn, name) do
    player = get_session_player(conn)

    if Map.get(player, :id) do
      Player.update_player(player, name)
    else
      Player.create_player(name)
    end
  end
end
