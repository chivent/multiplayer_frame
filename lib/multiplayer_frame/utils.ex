defmodule MultiplayerFrame.Utils do
  def generate_room_code do
    1..6
    |> Enum.reduce([], fn _el, acc -> [Enum.random(?A..?Z) | acc] end)
    |> List.to_string()
  end
end
