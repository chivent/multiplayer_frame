defmodule MultiplayerFrame.Plugs.EnsureRoomIsAvailable do
  import Plug.Conn, only: [halt: 1]
  alias MultiplayerFrame.{RoomServer, RoomSupervisor, Utils}

  def init(opts), do: opts

  def call(conn, _opts) do
    room_code = Plug.Conn.get_session(conn, "room_code")

    with {:valid_room?, true} <- valid_room?(room_code),
         {:room_available?, true} <- room_available?(room_code) do
      conn
    else
      {error_type, _} ->
        conn
        |> Utils.redirect_to_root(error_type)
        |> halt()
    end
  end

  defp valid_room?(room_code) do
    {:valid_room?, room_code && RoomSupervisor.room_exists?(room_code)}
  end

  defp room_available?(room_code) do
    {:room_available?, RoomServer.check_room_capacity(room_code)}
  end
end
