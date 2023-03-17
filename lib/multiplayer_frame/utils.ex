defmodule MultiplayerFrame.Utils do
  alias Phoenix.{Controller, LiveView}
  alias MultiplayerFrameWeb.Router.Helpers, as: Routes

  def generate_room_code do
    1..6
    |> Enum.reduce([], fn _el, acc -> [Enum.random(?A..?Z) | acc] end)
    |> List.to_string()
  end

  def redirect_to_root(socket_or_conn, error) do
    message =
      case error do
        :room_available? ->
          "The room you're looking for is unavailable."

        :already_in_room ->
          "You already have a window open in this room. Please join each room only once."

        :kicked ->
          "You have been kicked by the host."

        _ ->
          "The room you're looking for does not exist."
      end

    module =
      if %Plug.Conn{} == socket_or_conn do
        Controller
      else
        LiveView
      end

    socket_or_conn
    |> module.put_flash(:error, message)
    |> module.redirect(to: Routes.root_path(socket_or_conn, :index))
  end
end
