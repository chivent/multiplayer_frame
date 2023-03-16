defmodule MultiplayerFrame.Plugs.EnsurePlayerIsValid do
  import Plug.Conn, only: [halt: 1]
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  alias MultiplayerFrameWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, _opts) do
    player = Plug.Conn.get_session(conn, "player")

    if valid_player_information?(player) do
      conn
    else
      conn
      |> put_flash(:error, "Please enter a username before joining any rooms.")
      |> redirect(to: Routes.root_path(conn, :index))
      |> halt()
    end
  end

  defp valid_player_information?(player) do
    player && Map.has_key?(player, :id) && Map.has_key?(player, :name)
  end
end
