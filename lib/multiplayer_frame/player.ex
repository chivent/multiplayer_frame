defmodule MultiplayerFrame.Player do
  defstruct [:id, :name]

  def create_player(name) do
    %__MODULE__{}
    |> struct(%{name: name})
    |> Map.put(:id, Ecto.UUID.autogenerate())
  end

  def update_player(player, name) do
    player
    |> struct(%{name: name})
  end
end
