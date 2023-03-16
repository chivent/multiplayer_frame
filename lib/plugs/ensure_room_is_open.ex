defmodule MultiplayerFrame.Plugs.EnsureRoomIsOpen do
  import Plug.Conn, only: [halt: 1]
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  alias MultiplayerFrameWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  # TODO: Ensure room has room for more people
  def call(conn, _opts) do
    opts = get_opts(conn)

    if GenServer.whereis({:global, opts.id}) do
      conn
    else
      conn
      |> put_flash(:error, opts.error_message)
      |> redirect(to: Routes.root_path(conn, :index))
      |> halt()
    end
  end

  defp get_opts(%Plug.Conn{path_params: %{"id" => id}}) do
    # TODO: Ensure valid user
    %{
      id: id,
      error_message: "The room you're looking for does not exist"
    }
  end
end
