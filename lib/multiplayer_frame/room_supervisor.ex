defmodule MultiplayerFrame.RoomSupervisor do
  @moduledoc """
  Supervisor responsible for managing running RoomServer instances.

  Allows for creating new RoomServers processes on demand.
  """
  use DynamicSupervisor
  alias MultiplayerFrame.RoomServer

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  # TODO: Account for failed room creation
  def create_room(%MultiplayerFrame.Player{} = player) do
    room_id = MultiplayerFrame.Utils.generate_room_code()
    DynamicSupervisor.start_child(__MODULE__, {RoomServer, {room_id, player}})

    {:ok, room_id}
  end

  # def room_exists?(room_id) do
  # end

  # def delete_room(room_id) do
  # end
end
