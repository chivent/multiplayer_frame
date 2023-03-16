defmodule MultiplayerFrame.Plugs.EnsureRoomIsAvailable do
  import Plug.Conn, only: [halt: 1]
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  alias MultiplayerFrameWeb.Router.Helpers, as: Routes
  alias MultiplayerFrame.{RoomServer, RoomSupervisor}

  def init(opts), do: opts

  def call(conn, _opts) do
    room_code = Plug.Conn.get_session(conn, "room_code")

    with {:valid_room?, true} <- valid_room?(room_code),
         {:room_available?, true} <- room_available?(room_code) do
      conn
    else
      {error_type, _} ->
        conn
        |> put_flash(:error, error_message(error_type))
        |> redirect(to: Routes.root_path(conn, :index))
        |> halt()
    end
  end

  defp valid_room?(room_code) do
    {:valid_room?, room_code && RoomSupervisor.room_exists?(room_code)}
  end

  defp room_available?(room_code) do
    {:room_available?, RoomServer.check_room_capacity(room_code)}
  end

  defp error_message(type) do
    case type do
      :valid_room? ->
        "The room you're looking for does not exist."

      :room_available? ->
        "The room you're looking for is unavailable."
    end
  end
end
